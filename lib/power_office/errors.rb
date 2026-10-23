module PowerOffice
  module Errors
    class Error < StandardError
      attr_reader :response, :code

      def initialize(message = nil, response: nil, code: nil)
        @response = response
        @code = code
        super(message)
      end
    end

    class AuthenticationError < Error; end

    class ForbiddenError < Error; end

    class NotFoundError < Error; end

    class ValidationError < Error
      def errors
        response.validation_errors
      end
    end

    # PowerOffice throttles at 10 requests per second per subscription key
    # and asks callers to wait at least a second before retrying.
    class RateLimitError < Error; end

    class ServerError < Error; end

    class ConnectionError < Error; end

    class TimeoutError < Error; end

    class ConfigurationError < Error; end

    BY_STATUS = {
      400 => ValidationError,
      401 => AuthenticationError,
      403 => ForbiddenError,
      404 => NotFoundError,
      429 => RateLimitError
    }.freeze

    def self.from(response)
      error_class = BY_STATUS.fetch(response.status) { (response.status >= 500) ? ServerError : Error }
      error_class.new(response.error_message || "HTTP #{response.status}", response: response, code: response.status)
    end
  end
end
