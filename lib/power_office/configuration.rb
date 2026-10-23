module PowerOffice
  class Configuration < Data.define(:application_key, :subscription_key, :client_key, :environment)
    ENVIRONMENTS = {
      demo: "https://goapi.poweroffice.net/Demo",
      production: "https://goapi.poweroffice.net"
    }.freeze
    INTEGRATION_KEYS = %i[application_key subscription_key].freeze

    def initialize(application_key:, subscription_key:, environment:, client_key: nil)
      environment = environment.to_sym
      raise ArgumentError, "Unknown PowerOffice environment: #{environment}" unless ENVIRONMENTS.key?(environment)

      super
    end

    def validate!(keys = members - [:environment])
      missing = keys.select { |key| public_send(key).to_s.strip.empty? }
      return self if missing.empty?

      raise Errors::ConfigurationError, "Missing PowerOffice keys: #{missing.join(", ")}"
    end

    def api_url
      "#{base_url}/v2"
    end

    def token_url
      "#{base_url}/OAuth/Token"
    end

    private

    def base_url
      ENVIRONMENTS.fetch(environment)
    end
  end
end
