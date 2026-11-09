require_relative "../test_helper"

class PowerOffice::Resources::SalesOrdersTest < Minitest::Test
  include PowerOfficeTestHelpers

  def setup
    super
    respond_with_token
  end

  def test_create_complete_posts_the_order_with_its_lines
    order = {
      CustomerNo: 10001,
      ExternalImportReference: "servos-order-1042",
      SalesOrderLines: [{ProductCode: "LUNCH", Quantity: 2, ProductUnitPrice: 149.0}]
    }
    @connection.respond_with(status: 201, body: '{"Id":"5a2e"}')

    assert_equal({"Id" => "5a2e"}, client.sales_orders.create_complete(order).data)
    assert_request "POST", "#{API_URL}/SalesOrders/Complete"
    assert_equal order.to_json, last_request.body
  end

  def test_create_and_send_invoice_queues_the_order_for_delivery
    delivery = {DeliveryType: "PdfByEmail", EmailAddress: "invoice@example.no", VoucherDate: "2026-11-09"}
    @connection.respond_with(status: 202, body: '{"Id":"5a2e","DeliveryType":"PdfByEmail"}',
      headers: {"Location" => ["#{API_URL}/SalesOrders/SentState?id=5a2e"]})

    response = client.sales_orders.create_and_send_invoice("5a2e", delivery)

    assert_equal 202, response.status
    assert_request "POST", "#{API_URL}/SalesOrders/5a2e/CreateAndSendInvoice"
    assert_equal delivery.to_json, last_request.body
  end

  def test_create_and_send_invoice_defaults_to_power_offices_delivery_settings
    @connection.respond_with(status: 202, body: '{"Id":"5a2e","DeliveryType":"Auto"}')

    client.sales_orders.create_and_send_invoice("5a2e")

    assert_equal "{}", last_request.body
  end

  def test_sent_state_reports_the_delivery_of_one_order
    @connection.respond_with(body: '[{"Id":"5a2e","InvoiceNo":10042,"LastErrorMessage":null}]')

    state = client.sales_orders.sent_state("5a2e").data

    assert_equal 10042, state.first["InvoiceNo"]
    assert_request "GET", "#{API_URL}/SalesOrders/SentState?id=5a2e"
  end

  def test_sent_state_without_an_id_reports_every_order
    @connection.respond_with(status: 204)

    assert_equal [], client.sales_orders.sent_state.data
    assert_request "GET", "#{API_URL}/SalesOrders/SentState"
  end

  def test_a_failed_send_raises_with_power_offices_reason
    @connection.respond_with(status: 400, body: '{"title":"Invalid request","detail":"Customer has no e-mail address."}')

    error = assert_raises(PowerOffice::Errors::ValidationError) { client.sales_orders.create_and_send_invoice("5a2e") }
    assert_equal "Customer has no e-mail address.", error.message
  end

  def test_retrieve_complete_gets_the_order_with_its_lines
    @connection.respond_with(body: '{"Id":"5a2e","SalesOrderLines":[]}')

    assert_equal [], client.sales_orders.retrieve_complete("5a2e").data["SalesOrderLines"]
    assert_request "GET", "#{API_URL}/SalesOrders/5a2e/Complete"
  end

  def test_lines_gets_the_orders_lines
    @connection.respond_with(body: '[{"ProductCode":"LUNCH"}]')

    assert_equal [{"ProductCode" => "LUNCH"}], client.sales_orders.lines("5a2e").data
    assert_request "GET", "#{API_URL}/SalesOrders/5a2e/Lines"
  end

  def test_delete_removes_an_unsent_draft
    @connection.respond_with(body: "")

    client.sales_orders.delete("5a2e")

    assert_request "DELETE", "#{API_URL}/SalesOrders/5a2e"
  end
end
