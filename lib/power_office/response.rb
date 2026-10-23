module PowerOffice
  # Lists answer an empty 204 when there is nothing to return. ProblemDetails
  # keys are documented both PascalCase and camelCase.
  class Response
    attr_reader :status, :headers, :data

    def initialize(status:, body:, headers: {})
      @status = status
      @headers = headers.to_h { |name, values| [name.to_s.downcase, Array(values)] }
      @data = (status == 204) ? [] : parse(body)
    end

    def success?
      status.between?(200, 299)
    end

    def pagination
      header = headers["x-pagination"]&.first
      header && JSON.parse(header)
    rescue JSON::ParserError
      nil
    end

    def error_message
      case data
      when Hash
        problem("detail") || problem("title") || data["error_description"] || data["error"]
      when String
        data
      end
    end

    def validation_errors
      return {} unless data.is_a?(Hash)

      problem("errors") || {}
    end

    private

    def problem(key)
      data[key] || data[key.capitalize]
    end

    def parse(raw)
      return nil if raw.to_s.strip.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      raw
    end
  end
end
