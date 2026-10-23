require_relative "test_helper"

class PowerOffice::OnboardingTest < Minitest::Test
  include PowerOfficeTestHelpers

  INITIATE_URL = "#{API_URL}/Onboarding/Initiate".freeze
  FINALIZE_URL = "#{API_URL}/Onboarding/Finalize".freeze

  def test_builds_without_a_client_key
    assert_nil onboarding.configuration.client_key
  end

  def test_refuses_to_build_without_the_subscription_key
    error = assert_raises(PowerOffice::Errors::ConfigurationError) do
      PowerOffice::Onboarding.new(configuration: configuration(subscription_key: ""))
    end
    assert_equal "Missing PowerOffice keys: subscription_key", error.message
  end

  def test_initiate_sends_the_application_key_and_redirect_uri
    @connection.respond_with(body: {
      TemporaryUrl: "https://identity.poweroffice.net/ApiAuthV2?token=temp",
      ValidUntilDateTimeOffset: "2026-10-04T12:10:00Z"
    })

    response = onboarding.initiate(redirect_uri: "https://servos.dk/power_office", client_organization_no: "123456789")

    assert_equal "https://identity.poweroffice.net/ApiAuthV2?token=temp", response.data["TemporaryUrl"]
    assert_request "POST", INITIATE_URL
    assert_equal(
      {"ApplicationKey" => "app", "ClientOrganizationNo" => "123456789", "RedirectUri" => "https://servos.dk/power_office"},
      JSON.parse(last_request.body)
    )
  end

  def test_initiate_sends_only_the_subscription_key_and_never_authenticates
    @connection.respond_with(body: "{}")

    onboarding.initiate(redirect_uri: "https://servos.dk/power_office")

    assert_equal "sub", last_request["Ocp-Apim-Subscription-Key"]
    assert_equal "application/json", last_request["Content-Type"]
    refute last_request.key?("Authorization")
    assert_equal 1, @connection.requests.size
  end

  def test_initiate_without_an_organization_number_leaves_the_client_choice_to_the_user
    @connection.respond_with(body: "{}")

    onboarding.initiate(redirect_uri: "https://servos.dk/power_office")

    assert_equal({"ApplicationKey" => "app", "RedirectUri" => "https://servos.dk/power_office"},
      JSON.parse(last_request.body))
  end

  def test_initiate_treats_a_blank_organization_number_as_unset
    @connection.respond_with(body: "{}")

    onboarding.initiate(redirect_uri: "https://servos.dk/power_office", client_organization_no: "")

    assert_equal({"ApplicationKey" => "app", "RedirectUri" => "https://servos.dk/power_office"},
      JSON.parse(last_request.body))
  end

  def test_finalize_exchanges_the_token_for_the_onboarded_clients_keys
    clients = [{"ClientKey" => "f1ba4158", "ClientName" => "ABC AS", "ClientOrganizationNumber" => "123456789"}]
    @connection.respond_with(body: {OnboardedClientsInformation: clients, UserEmail: "jon@example.com"})

    assert_equal clients, onboarding.finalize("temp").data["OnboardedClientsInformation"]
    assert_request "POST", FINALIZE_URL
    assert_equal({"OnboardingToken" => "temp"}, JSON.parse(last_request.body))
  end

  def test_a_rejected_request_raises_the_mapped_error
    @connection.respond_with(status: 400, body: '{"Title":"Onboarding failed.","Detail":"Expired"}')

    error = assert_raises(PowerOffice::Errors::ValidationError) { onboarding.finalize("stale") }
    assert_equal "Expired", error.message
  end

  private

  def onboarding
    PowerOffice::Onboarding.new(configuration: configuration, connection: @connection)
  end
end
