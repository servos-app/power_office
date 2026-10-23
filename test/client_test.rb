require_relative "test_helper"

class PowerOffice::ClientTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_refuses_to_build_without_a_client_key
    assert_raises(PowerOffice::Errors::ConfigurationError) do
      PowerOffice::Client.new(client_key: "", configuration: configuration)
    end
  end

  def test_adds_the_client_key_to_the_integration_configuration
    built = PowerOffice::Client.new(client_key: "client", configuration: configuration)

    assert_equal "client", built.configuration.client_key
    assert_equal "sub", built.configuration.subscription_key
  end

  def test_sends_the_token_and_the_subscription_key
    respond_with_token
    @connection.respond_with(body: "[]")

    client.get("/Customers")

    assert_request "GET", "#{API_URL}/Customers"
    assert_equal "Bearer token-1", last_request["Authorization"]
    assert_equal "sub", last_request["Ocp-Apim-Subscription-Key"]
  end

  def test_reuses_the_token_until_it_nears_expiry
    clock = FakeClock.new
    clocked = client(clock: clock)
    respond_with_token.respond_with(body: "[]").respond_with(body: "[]")

    clocked.get("/VatCodes")
    clock.travel(18 * 60)
    clocked.get("/VatCodes")
    assert_equal 1, @connection.token_requests.size

    respond_with_token("token-2").respond_with(body: "[]")
    clock.travel(60)
    clocked.get("/VatCodes")
    assert_equal 2, @connection.token_requests.size
  end

  def test_a_401_fetches_a_fresh_token_and_resends_once
    respond_with_token("token-1").respond_with(status: 401)
    respond_with_token("token-2").respond_with(body: '[{"Id":7}]')

    assert_equal [{"Id" => 7}], client.get("/Projects").data
    assert_equal ["Bearer token-1", "Bearer token-2"], @connection.api_authorizations
  end

  def test_a_second_401_raises_authentication_error
    respond_with_token.respond_with(status: 401)
    respond_with_token.respond_with(status: 401)

    assert_raises(PowerOffice::Errors::AuthenticationError) { client.get("/Projects") }
    assert_equal 2, @connection.api_requests.size
  end

  def test_an_error_status_raises_the_mapped_error
    respond_with_token.respond_with(status: 404)

    assert_raises(PowerOffice::Errors::NotFoundError) { client.get("/Customers/9") }
  end

  def test_post_sends_a_json_body
    respond_with_token.respond_with(status: 201, body: '{"Id":1}')

    client.post("/Customers", body: {Name: "Fjord AS"})

    assert_request "POST", "#{API_URL}/Customers"
    assert_equal '{"Name":"Fjord AS"}', last_request.body
    assert_equal "application/json", last_request["Content-Type"]
  end
end
