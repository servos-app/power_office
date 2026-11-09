require_relative "../test_helper"

class PowerOffice::Resources::VouchersTest < Minitest::Test
  include PowerOfficeTestHelpers

  def setup
    super
    respond_with_token
  end

  def test_create_manual_journal_posts_to_the_general_ledger
    voucher = {
      VoucherDate: "2026-10-03",
      CurrencyCode: "NOK",
      VoucherLines: [{AccountId: 1, CurrencyAmount: 1000}, {AccountId: 2, CurrencyAmount: -1000}]
    }
    @connection.respond_with(status: 201, body: '{"Id":"9f1c"}')

    assert_equal({"Id" => "9f1c"}, client.vouchers.create_manual_journal(voucher).data)
    assert_request "POST", "#{API_URL}/Vouchers/ManualJournals"
    assert_equal voucher.to_json, last_request.body
  end

  def test_retrieve_manual_journal_gets_the_voucher_by_id
    @connection.respond_with(body: '{"Id":"9f1c"}')

    assert_equal({"Id" => "9f1c"}, client.vouchers.retrieve_manual_journal("9f1c").data)
    assert_request "GET", "#{API_URL}/Vouchers/ManualJournals/9f1c"
  end

  def test_create_outgoing_invoice_journal_posts_an_invoice_issued_elsewhere
    invoice = {
      InvoiceNo: 1042,
      VoucherDate: "2026-11-09",
      DueDate: "2026-11-23",
      CurrencyCode: "NOK",
      CurrencyAmount: 1250,
      CustomerAccountId: 7,
      VoucherLines: [{AccountId: 3, CurrencyAmount: 1250, VatId: 5}]
    }
    @connection.respond_with(status: 201, body: '{"Id":"9f1c"}')

    assert_equal({"Id" => "9f1c"}, client.vouchers.create_outgoing_invoice_journal(invoice).data)
    assert_request "POST", "#{API_URL}/Vouchers/OutgoingInvoiceJournals"
    assert_equal invoice.to_json, last_request.body
  end

  def test_retrieve_outgoing_invoice_journal_gets_the_voucher_by_id
    @connection.respond_with(body: '{"Id":"9f1c"}')

    client.vouchers.retrieve_outgoing_invoice_journal("9f1c")

    assert_request "GET", "#{API_URL}/Vouchers/OutgoingInvoiceJournals/9f1c"
  end

  def test_create_outgoing_credit_note_journal_posts_a_credit_note
    credit_note = {InvoiceNo: 1043, CurrencyAmount: -1250, VoucherLines: [{AccountId: 3, CurrencyAmount: -1250, VatId: 5}]}
    @connection.respond_with(status: 201, body: '{"Id":"7d3a"}')

    client.vouchers.create_outgoing_credit_note_journal(credit_note)

    assert_request "POST", "#{API_URL}/Vouchers/OutgoingCreditNoteJournals"
    assert_equal credit_note.to_json, last_request.body
  end

  def test_retrieve_outgoing_credit_note_journal_gets_the_voucher_by_id
    @connection.respond_with(body: '{"Id":"7d3a"}')

    client.vouchers.retrieve_outgoing_credit_note_journal("7d3a")

    assert_request "GET", "#{API_URL}/Vouchers/OutgoingCreditNoteJournals/7d3a"
  end

  def test_a_reused_invoice_reference_raises_conflict
    @connection.respond_with(status: 409, body: '{"title":"Conflict","detail":"InvoiceNo 1042 already exists."}')

    assert_raises(PowerOffice::Errors::ConflictError) { client.vouchers.create_outgoing_invoice_journal({InvoiceNo: 1042}) }
  end

  def test_account_transactions_lists_under_power_offices_filters
    @connection.respond_with(body: '[{"VoucherId":"9f1c"}]')

    transactions = client.account_transactions.list(page_number: 1, fromDate: "2026-10-03", toDate: "2026-10-03")

    assert_equal [{"VoucherId" => "9f1c"}], transactions.data
    assert_request "GET", "#{API_URL}/AccountTransactions?PageNumber=1&fromDate=2026-10-03&toDate=2026-10-03"
  end
end
