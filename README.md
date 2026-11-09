# PowerOffice

A client for the PowerOffice Go API v2: client-credentials authentication, onboarding and the accounting resources SERVOS posts to. Plain Ruby, no runtime dependencies.

## Installation

```ruby
gem "power_office", github: "servos-app/power_office"
```

## Outgoing invoices

There are two ways to get an invoice into PowerOffice:

- **Have Go issue it.** Create a sales order (an invoice draft), then ask Go to turn it into an invoice and deliver it by e-mail, EHF, eFaktura or AvtaleGiro. Delivery is queued, so poll the sent state.

  ```ruby
  order = client.sales_orders.create_complete(
    CustomerNo: 10001,
    ExternalImportReference: "servos-order-1042",
    SalesOrderLines: [{ProductCode: "LUNCH", Quantity: 2, ProductUnitPrice: 149.0}]
  ).data
  client.sales_orders.create_and_send_invoice(order["Id"], DeliveryType: "PdfByEmail", VoucherDate: "2026-11-09")
  client.sales_orders.sent_state(order["Id"]).data.first # => {"InvoiceNo" => 10042, "SentDateTimeOffset" => ..., "LastErrorMessage" => nil}
  ```

- **Post an invoice issued elsewhere.** Post it to the ledger and the customer's sub-ledger with `client.vouchers.create_outgoing_invoice_journal` (`create_outgoing_credit_note_journal` for credit notes).

Either way, `client.outgoing_invoices.list`, `retrieve` and `lines` read the sent invoices back.

## Development

```sh
bundle install
bundle exec rake test
```

## License

MIT, see [LICENSE](LICENSE).
