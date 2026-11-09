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
    #
    # Invoices issued outside Go are posted as outgoing invoice vouchers: the
    # gross CurrencyAmount lands on the customer's sub-ledger account
    # (CustomerAccountId, not the customer's Id), and the lines, which must sum
    # to it, carry the sales postings with their VAT codes. Credit notes take
    # negative amounts. InvoiceNo must be unique on the client. To have Go
    # issue and deliver the invoice itself, use SalesOrders instead.
    #
    # @example
    #   client.vouchers.create_outgoing_invoice_journal(
    #     InvoiceNo: 1042,
    #     VoucherDate: "2026-11-09",
    #     DueDate: "2026-11-23",
    #     CurrencyCode: "NOK",
    #     CurrencyAmount: 1250,
    #     CustomerAccountId: customer_account_id,
    #     ExternalImportReference: "servos-invoice-1042",
    #     VoucherLines: [{AccountId: sales_id, CurrencyAmount: 1250, VatId: high_rate_id}]
    #   )
    class Vouchers < Resource
      def create_manual_journal(body)
        client.post("#{resource_path}/ManualJournals", body: body)
      end

      def retrieve_manual_journal(id)
        client.get("#{resource_path}/ManualJournals/#{id}")
      end

      def create_outgoing_invoice_journal(body)
        client.post("#{resource_path}/OutgoingInvoiceJournals", body: body)
      end

      def retrieve_outgoing_invoice_journal(id)
        client.get("#{resource_path}/OutgoingInvoiceJournals/#{id}")
      end

      def create_outgoing_credit_note_journal(body)
        client.post("#{resource_path}/OutgoingCreditNoteJournals", body: body)
      end

      def retrieve_outgoing_credit_note_journal(id)
        client.get("#{resource_path}/OutgoingCreditNoteJournals/#{id}")
      end

      protected

      def resource_path
        "/Vouchers"
      end
    end
  end
end
