require_relative "../test_helper"

class PowerOffice::Resources::OutgoingInvoicesTest < Minitest::Test
  include PowerOfficeTestHelpers

  def setup
    super
    respond_with_token
  end

  def test_list_filters_sent_invoices_under_power_offices_names
    @connection.respond_with(body: '[{"InvoiceNo":10042}]')

    invoices = client.outgoing_invoices.list(page_size: 50, externalImportReferences: "servos-order-1042")

    assert_equal [{"InvoiceNo" => 10042}], invoices.data
    assert_request "GET", "#{API_URL}/OutgoingInvoices?PageSize=50&externalImportReferences=servos-order-1042"
  end

  def test_retrieve_gets_the_invoice_by_id
    @connection.respond_with(body: '{"Id":"9f1c","InvoiceNo":10042}')

    assert_equal 10042, client.outgoing_invoices.retrieve("9f1c").data["InvoiceNo"]
    assert_request "GET", "#{API_URL}/OutgoingInvoices/9f1c"
  end

  def test_lines_pages_through_the_invoices_lines
    @connection.respond_with(body: '[{"Description":"Lunch"}]')

    lines = client.outgoing_invoices.lines("9f1c", page_number: 2)

    assert_equal [{"Description" => "Lunch"}], lines.data
    assert_request "GET", "#{API_URL}/OutgoingInvoices/9f1c/Lines?PageNumber=2"
  end
end
