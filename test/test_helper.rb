require "minitest/autorun"
require_relative "../lib/power_office"

# Client sets Authorization on the request it resends after a 401, so the
# header each send carried is recorded apart from the request object.
class FakeConnection
  attr_reader :requests, :authorizations

  def initialize
    @requests = []
    @authorizations = []
    @responses = []
  end

  def respond_with(status: 200, body: "", headers: {})
    @responses << PowerOffice::Response.new(status: status, body: body.is_a?(String) ? body : body.to_json,
      headers: headers)
    self
  end

  def perform(request)
    @requests << request
    @authorizations << request["Authorization"]
    @responses.shift || raise("FakeConnection has no response queued for #{request.method} #{request.uri}")
  end

  def last_request = requests.last

  def token_requests = requests.select { |request| token_request?(request) }

  def api_requests = requests.reject { |request| token_request?(request) }

  def api_authorizations
    requests.zip(authorizations).reject { |request, _| token_request?(request) }.map(&:last)
  end

  private

  def token_request?(request) = request.uri.path.end_with?("/OAuth/Token")
end

class FakeClock
  attr_reader :now

  def initialize(now = Time.utc(2026, 10, 3, 12, 0))
    @now = now
  end

  def travel(seconds)
    @now += seconds
  end
end

module PowerOfficeTestHelpers
  TOKEN_URL = "https://goapi.poweroffice.net/Demo/OAuth/Token".freeze
  API_URL = "https://goapi.poweroffice.net/Demo/v2".freeze

  def setup
    @connection = FakeConnection.new
  end

  private

  def configuration(**overrides)
    PowerOffice::Configuration.new(application_key: "app", subscription_key: "sub", environment: :demo, **overrides)
  end

  def client(clock: Time)
    PowerOffice::Client.new(client_key: "client", configuration: configuration, connection: @connection, clock: clock)
  end

  def respond_with_token(value = "token-1")
    @connection.respond_with(body: {access_token: value, expires_in: 1200})
  end

  def response(status, body, headers = {})
    PowerOffice::Response.new(status: status, body: body, headers: headers)
  end

  def last_request = @connection.last_request

  def assert_request(method, url, request = last_request)
    assert_equal method, request.method
    assert_equal url, request.uri.to_s
  end
end
