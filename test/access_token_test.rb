require_relative "test_helper"

class PowerOffice::AccessTokenTest < Minitest::Test
  def test_expires_a_minute_before_power_offices_20_minute_lifetime
    issued_at = Time.utc(2026, 10, 3, 12, 0)
    token = PowerOffice::AccessToken.from_response({"access_token" => "jwt", "expires_in" => 1200}, now: issued_at)

    refute token.expired?(now: issued_at + (18 * 60) + 59)
    assert token.expired?(now: issued_at + (19 * 60))
  end
end
