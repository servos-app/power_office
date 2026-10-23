module PowerOffice
  module Resources
    # Manual journals are the voucher type for posting balanced entries from
    # another system. Lines reference accounts by PowerOffice record id (the
    # "Id" from general_ledger_accounts.list), not by account number. Vouchers
    # arrive unposted (IsPosted: false) for the customer to post in Go.
    #
    # @example
    #   client.journal_entry_vouchers.create_manual_journal(
    #     VoucherDate: "2026-10-03",
    #     CurrencyCode: "NOK",
    #     ExternalImportReference: "servos-2026-10-03",
    #     ManualVoucherLines: [{DebitAccountId: receivables_id, CreditAccountId: sales_id, CurrencyAmount: 1000}]
    #   )
    class JournalEntryVouchers < Resource
      def create_manual_journal(body)
        client.post("#{resource_path}/ManualJournals", body: body)
      end

      def retrieve_manual_journal(id)
        client.get("#{resource_path}/ManualJournals/#{id}")
      end

      protected

      def resource_path
        "/JournalEntryVouchers"
      end
    end
  end
end
