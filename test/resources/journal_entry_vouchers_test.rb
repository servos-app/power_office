require_relative "../test_helper"

class PowerOffice::Resources::JournalEntryVouchersTest < Minitest::Test
  include PowerOfficeTestHelpers

  def setup
    super
    respond_with_token
  end

  def test_create_manual_journal_posts_to_manual_journals
    voucher = {
      VoucherDate: "2026-10-03",
      CurrencyCode: "NOK",
      ManualVoucherLines: [{DebitAccountId: 1500, CreditAccountId: 3000, CurrencyAmount: 1000}]
    }
    @connection.respond_with(status: 201, body: '{"Id":42}')

    assert_equal({"Id" => 42}, client.journal_entry_vouchers.create_manual_journal(voucher).data)
    assert_request "POST", "#{API_URL}/JournalEntryVouchers/ManualJournals"
    assert_equal voucher.to_json, last_request.body
  end

  def test_retrieve_manual_journal_gets_the_voucher_by_id
    @connection.respond_with(body: '{"Id":42}')

    assert_equal({"Id" => 42}, client.journal_entry_vouchers.retrieve_manual_journal(42).data)
    assert_request "GET", "#{API_URL}/JournalEntryVouchers/ManualJournals/42"
  end
end
