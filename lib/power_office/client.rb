module PowerOffice
  class Client
    attr_reader :configuration

    def initialize(client_key:, configuration:, connection: Connection, clock: Time)
      @configuration = configuration.with(client_key: client_key).validate!
      @connection = connection
      @clock = clock
    end

    def customers
      @customers ||= Resources::Customers.new(self)
    end

    def departments
      @departments ||= Resources::Departments.new(self)
    end

    def general_ledger_accounts
      @general_ledger_accounts ||= Resources::GeneralLedgerAccounts.new(self)
    end

    def journal_entry_vouchers
      @journal_entry_vouchers ||= Resources::JournalEntryVouchers.new(self)
    end

    def products
      @products ||= Resources::Products.new(self)
    end

    def projects
      @projects ||= Resources::Projects.new(self)
    end

    def vat_codes
      @vat_codes ||= Resources::VatCodes.new(self)
    end

    def integration_information
      get("/ClientIntegrationInformation")
    end

    # Revokes this client key, so the customer has to onboard again to reconnect.
    def remove_integration
      delete("/Offboarding/RemoveIntegration")
    end

    def get(path, params: {})
      perform(Request.get(configuration, path, params: params))
    end

    def post(path, body:)
      perform(Request.post(configuration, path, body: body))
    end

    def delete(path)
      perform(Request.delete(configuration, path))
    end

    private

    # A token can be revoked server-side before our local expiry, so a 401
    # earns one resend with a fresh token.
    def perform(request)
      response = perform_authorized(request)
      if response.status == 401
        @access_token = nil
        response = perform_authorized(request)
      end

      raise Errors.from(response) unless response.success?

      response
    end

    def perform_authorized(request)
      request["Authorization"] = "Bearer #{access_token.value}"
      @connection.perform(request)
    end

    def access_token
      @access_token = nil if @access_token&.expired?(now: @clock.now)
      @access_token ||= Authenticator.new(configuration, connection: @connection, clock: @clock).authenticate
    end
  end
end
