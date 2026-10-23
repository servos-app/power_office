require_relative "test_helper"

class PowerOffice::RetrievableTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_retrieve_gets_the_record_by_id
    respond_with_token.respond_with(body: '{"Id":5}')

    assert_equal({"Id" => 5}, client.products.retrieve(5).data)
    assert_request "GET", "#{API_URL}/Products/5"
  end
end
