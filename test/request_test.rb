require_relative "test_helper"

class PowerOffice::RequestTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_get_carries_the_query_and_the_subscription_key
    request = PowerOffice::Request.get(configuration, "/Customers", params: {PageNumber: 2})

    assert_equal "#{API_URL}/Customers?PageNumber=2", request.uri.to_s
    assert_equal "sub", request["Ocp-Apim-Subscription-Key"]
    assert_equal "application/json", request["Accept"]
    assert_equal PowerOffice::Request::USER_AGENT, request["User-Agent"]
  end

  def test_post_sends_a_json_body
    request = PowerOffice::Request.post(configuration, "/Customers", body: {Name: "Fjord AS"})

    assert_equal '{"Name":"Fjord AS"}', request.body
    assert_equal "application/json", request["Content-Type"]
    assert_equal "sub", request["Ocp-Apim-Subscription-Key"]
  end

  def test_token_sends_the_application_and_client_keys_as_basic_auth_with_the_shared_headers
    request = PowerOffice::Request.token(configuration(client_key: "client"))

    assert_equal TOKEN_URL, request.uri.to_s
    assert_equal "Basic #{["app:client"].pack("m0")}", request["Authorization"]
    assert_equal "grant_type=client_credentials", request.body
    assert_equal "sub", request["Ocp-Apim-Subscription-Key"]
    assert_equal PowerOffice::Request::USER_AGENT, request["User-Agent"]
  end
end
