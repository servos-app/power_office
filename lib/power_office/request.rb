module PowerOffice
  module Request
    USER_AGENT = "SERVOS (https://servos.dk)"

    def self.get(configuration, path, params: {})
      uri = api_uri(configuration, path)
      uri.query = URI.encode_www_form(params) if params.any?
      build(Net::HTTP::Get, configuration, uri)
    end

    def self.delete(configuration, path)
      build(Net::HTTP::Delete, configuration, api_uri(configuration, path))
    end

    def self.post(configuration, path, body:)
      request = build(Net::HTTP::Post, configuration, api_uri(configuration, path))
      request["Content-Type"] = "application/json"
      request.body = body.to_json
      request
    end

    def self.token(configuration)
      request = build(Net::HTTP::Post, configuration, URI(configuration.token_url))
      request.basic_auth(configuration.application_key, configuration.client_key)
      request.set_form_data(grant_type: "client_credentials")
      request
    end

    def self.api_uri(configuration, path)
      URI("#{configuration.api_url}#{path}")
    end
    private_class_method :api_uri

    def self.build(request_class, configuration, uri)
      request = request_class.new(uri)
      request["Ocp-Apim-Subscription-Key"] = configuration.subscription_key
      request["Accept"] = "application/json"
      request["User-Agent"] = USER_AGENT
      request
    end
    private_class_method :build
  end
end
