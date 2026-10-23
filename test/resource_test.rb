require_relative "test_helper"

class PowerOffice::ResourceTest < Minitest::Test
  include PowerOfficeTestHelpers

  def setup
    super
    respond_with_token
  end

  def test_list_sends_paging_and_endpoint_filters_under_power_offices_names
    @connection.respond_with(body: '[{"Id":1}]')

    customers = client.customers.list(page_number: 2, page_size: 100, customerNos: "10000-10999")

    assert_equal [{"Id" => 1}], customers.data
    assert_request "GET", "#{API_URL}/Customers?PageNumber=2&PageSize=100&customerNos=10000-10999"
  end

  def test_list_is_empty_when_power_office_answers_204
    @connection.respond_with(status: 204, body: "")

    assert_equal [], client.customers.list.data
  end

  def test_list_without_paging_sends_no_query
    @connection.respond_with(body: "[]")

    assert_equal [], client.vat_codes.list.data
    assert_request "GET", "#{API_URL}/VatCodes"
  end
end
