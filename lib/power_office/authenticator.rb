module PowerOffice
  class Authenticator
    def initialize(configuration, connection: Connection, clock: Time)
      @configuration = configuration
      @connection = connection
      @clock = clock
    end

    def authenticate
      issued_at = clock.now
      response = connection.perform(Request.token(configuration))
      raise token_error(response) unless response.success?

      AccessToken.from_response(response.data, now: issued_at)
    end

    private

    attr_reader :configuration, :connection, :clock

    # A wrong application or client key comes back as 400 invalid_client.
    def token_error(response)
      return Errors.from(response) unless response.status == 400

      Errors::AuthenticationError.new(response.error_message, response: response, code: response.status)
    end
  end
end
