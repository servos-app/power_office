module PowerOffice
  module Resources
    # Sales orders are Go's invoice drafts, and the way to issue an invoice
    # from Go: create the order with its lines, then ask Go to turn it into an
    # invoice (or a credit note, when the lines sum negative) and deliver it.
    # Delivery is queued, so poll #sent_state until SentDateTimeOffset is set
    # or LastErrorMessage explains the failure. The sent invoice is then
    # readable through OutgoingInvoices.
    #
    # Creating needs the SalesOrders full privilege and sending its
    # sendInvoice privilege. ExternalImportReference is accepted once per
    # client, so a resent create can't make a second draft.
    #
    # @example
    #   order = client.sales_orders.create_complete(
    #     CustomerNo: 10001,
    #     CurrencyCode: "NOK",
    #     ExternalImportReference: "servos-order-1042",
    #     SalesOrderLines: [{ProductCode: "LUNCH", Quantity: 2, ProductUnitPrice: 149.0}]
    #   ).data
    #   client.sales_orders.create_and_send_invoice(order["Id"], DeliveryType: "PdfByEmail",
    #     EmailAddress: "invoice@example.no", VoucherDate: "2026-11-09")
    #   client.sales_orders.sent_state(order["Id"]).data
    #   # => [{"Id" => "...", "InvoiceNo" => 10042, "SentDateTimeOffset" => "...", "LastErrorMessage" => nil, ...}]
    class SalesOrders < Resource
      include Retrievable

      def create_complete(body)
        client.post("#{resource_path}/Complete", body: body)
      end

      # The order with its lines; #retrieve returns the header only.
      def retrieve_complete(id)
        client.get("#{resource_path}/#{id}/Complete")
      end

      def lines(id, page_number: nil, page_size: nil, **params)
        get_page("#{resource_path}/#{id}/Lines", page_number: page_number, page_size: page_size, **params)
      end

      # Removes a draft that hasn't been sent.
      def delete(id)
        client.delete("#{resource_path}/#{id}")
      end

      # Queues the order for invoicing and delivery and answers 202. Every key
      # is optional: DeliveryType (Auto by default, or PdfByEmail,
      # PdfPrintForDownload, EHF, Efaktura, AvtaleGiro), EmailAddress (the
      # customer's invoice address by default), VoucherDate (today by default,
      # and the invoice date) and OverrideDueDate.
      def create_and_send_invoice(id, body = {})
        client.post("#{resource_path}/#{id}/CreateAndSendInvoice", body: body)
      end

      # Delivery state of one sales order, or of all of them without an id.
      def sent_state(id = nil)
        client.get("#{resource_path}/SentState", params: {id: id}.compact)
      end

      protected

      def resource_path
        "/SalesOrders"
      end
    end
  end
end
