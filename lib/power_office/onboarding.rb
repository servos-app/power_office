module PowerOffice
  # Activates SERVOS on a customer's PowerOffice client(s) and returns their
  # client keys. It runs before any client key exists, so it sends only the
  # subscription key and never authenticates.
  #
  # @example
  #   onboarding = PowerOffice::Onboarding.new(configuration: Rails.configuration.x.power_office)
  #   onboarding.initiate(redirect_uri: "https://servos.dk/power_office/onboarding").data["TemporaryUrl"]
  #   # PowerOffice sends the user back to the redirect URI with a token
  #   onboarding.finalize(token).data["OnboardedClientsInformation"]
  #
  # @see https://developer.poweroffice.net/workflows/onboarding
  class Onboarding
    attr_reader :configuration

    def initialize(configuration:, connection: Connection)
      @configuration = configuration.validate!(Configuration::INTEGRATION_KEYS)
      @connection = connection
    end

    def initiate(redirect_uri:, client_organization_no: nil)
      body = {
        ApplicationKey: configuration.application_key,
        ClientOrganizationNo: (client_organization_no unless client_organization_no.to_s.strip.empty?),
        RedirectUri: redirect_uri
      }
      perform(Request.post(configuration, "/Onboarding/Initiate", body: body.compact))
    end

    def finalize(token)
      perform(Request.post(configuration, "/Onboarding/Finalize", body: {OnboardingToken: token}))
    end

    private

    def perform(request)
      response = @connection.perform(request)
      raise Errors.from(response) unless response.success?

      response
    end
  end
end
