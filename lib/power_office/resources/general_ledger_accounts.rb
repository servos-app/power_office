module PowerOffice
  module Resources
    class GeneralLedgerAccounts < Resource
      include Retrievable

      protected

      def resource_path
        "/GeneralLedgerAccounts"
      end
    end
  end
end
