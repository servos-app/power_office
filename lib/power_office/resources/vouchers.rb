module PowerOffice
  module Resources
    # Vouchers posted straight to the general ledger, unlike the drafts in
    # JournalEntryVouchers. Lines carry signed gross amounts (debit positive)
    # with the VAT code that splits them, reference accounts by PowerOffice
    # record id, and must balance. PowerOffice accepts an
    # ExternalImportReference once per client and answers a second post with
    # ConflictError, so a resend can't book the same voucher twice.
    #
    # @example
    #   client.vouchers.create_manual_journal(
    #     VoucherDate: "2026-10-03",
    #     CurrencyCode: "NOK",
    #     ExternalImportReference: "0b7c5e9e-...",
    #     VoucherLines: [
    #       {AccountId: card_clearing_id, CurrencyAmount: 1000, PostingDate: "2026-10-03"},
    #       {AccountId: sales_id, CurrencyAmount: -1000, PostingDate: "2026-10-03", VatId: high_rate_id}
    #     ]
    #   )
    class Vouchers < Resource
      def create_manual_journal(body)
        client.post("#{resource_path}/ManualJournals", body: body)
      end

      def retrieve_manual_journal(id)
        client.get("#{resource_path}/ManualJournals/#{id}")
      end

      protected

      def resource_path
        "/Vouchers"
      end
    end
  end
end
