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

  def test_account_transactions_lists_under_power_offices_filters
    @connection.respond_with(body: '[{"VoucherId":"9f1c"}]')

    transactions = client.account_transactions.list(page_number: 1, fromDate: "2026-10-03", toDate: "2026-10-03")

    assert_equal [{"VoucherId" => "9f1c"}], transactions.data
    assert_request "GET", "#{API_URL}/AccountTransactions?PageNumber=1&fromDate=2026-10-03&toDate=2026-10-03"
  end
end
