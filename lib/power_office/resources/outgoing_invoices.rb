module PowerOffice
  module Resources
    # Invoices and credit notes the client has sent, whether issued from Go
    # through SalesOrders#create_and_send_invoice or posted as vouchers. Read
    # only: list and retrieve return the invoice header, #lines its lines.
    # Filters include `invoiceNos:`, `externalImportReferences:`, `fromDate:`,
    # `toDate:`, `onlyUnpaidInvoices:` and `sentDateTimeOffsetGreaterThan:`.
    #
    # @example
    #   client.outgoing_invoices.list(externalImportReferences: "servos-order-1042")
    class OutgoingInvoices < Resource
      include Retrievable

      # Lines may be incomplete or missing on invoices imported into Go rather
      # than generated and sent from it.
      def lines(id, page_number: nil, page_size: nil, **params)
        get_page("#{resource_path}/#{id}/Lines", page_number: page_number, page_size: page_size, **params)
      end

      protected

      def resource_path
        "/OutgoingInvoices"
      end
    end
  end
end
