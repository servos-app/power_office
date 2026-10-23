require_relative "test_helper"

class PowerOffice::AuthenticatorTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_returns_the_token_power_office_issues
    respond_with_token("jwt")

    assert_equal "jwt", authenticator.authenticate.value
    assert_request "POST", TOKEN_URL
  end

  def test_the_token_expires_from_when_it_was_requested
    clock = FakeClock.new
    respond_with_token

    token = authenticator(clock: clock).authenticate

    assert_equal clock.now + 1200, token.expires_at
  end

  def test_a_rejected_key_raises_authentication_error_with_power_offices_reason
    @connection.respond_with(status: 400, body: '{"error":"invalid_client","error_description":"Unknown client key"}')

    error = assert_raises(PowerOffice::Errors::AuthenticationError) { authenticator.authenticate }
    assert_equal "Unknown client key", error.message
  end

  def test_a_throttled_token_request_raises_rate_limit_error_not_authentication_error
    @connection.respond_with(status: 429)

    assert_raises(PowerOffice::Errors::RateLimitError) { authenticator.authenticate }
  end

  private

  def authenticator(clock: Time)
    PowerOffice::Authenticator.new(configuration(client_key: "client"), connection: @connection, clock: clock)
  end
end
