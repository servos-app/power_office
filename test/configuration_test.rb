require_relative "test_helper"

class PowerOffice::ConfigurationTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_demo_urls_carry_the_demo_path_segment
    demo = configuration(environment: :demo)

    assert_equal "https://goapi.poweroffice.net/Demo/v2", demo.api_url
    assert_equal "https://goapi.poweroffice.net/Demo/OAuth/Token", demo.token_url
  end

  def test_production_urls_sit_at_the_host_root
    production = configuration(environment: "production")

    assert_equal "https://goapi.poweroffice.net/v2", production.api_url
    assert_equal "https://goapi.poweroffice.net/OAuth/Token", production.token_url
  end

  def test_rejects_an_unknown_environment
    assert_raises(ArgumentError) { configuration(environment: :staging) }
  end

  def test_validate_returns_the_configuration_when_every_key_is_present
    complete = configuration(client_key: "client")

    assert_same complete, complete.validate!
  end

  def test_validate_names_every_blank_key
    incomplete = configuration(application_key: "", subscription_key: "  ", client_key: nil)

    error = assert_raises(PowerOffice::Errors::ConfigurationError) { incomplete.validate! }
    assert_equal "Missing PowerOffice keys: application_key, subscription_key, client_key", error.message
  end

  def test_validate_checks_only_the_keys_it_is_given
    without_client = configuration(client_key: nil)

    assert_same without_client, without_client.validate!(PowerOffice::Configuration::INTEGRATION_KEYS)
  end
end
