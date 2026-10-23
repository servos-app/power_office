require_relative "test_helper"

class PowerOffice::ResponseTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_data_is_the_bare_json_array_power_office_returns_for_collections
    assert_equal [{"Id" => 1}], response(200, '[{"Id":1}]').data
  end

  def test_pagination_parses_the_x_pagination_header
    pagination = response(200, "[]",
      "x-pagination" => ['{"totalPages":2,"nextPageLink":"/v2/Customers?pageNumber=2"}']).pagination

    assert_equal({"totalPages" => 2, "nextPageLink" => "/v2/Customers?pageNumber=2"}, pagination)
  end

  def test_pagination_is_nil_without_the_header
    assert_nil response(200, "[]").pagination
  end

  def test_error_message_prefers_the_problem_details_detail_in_either_casing
    assert_equal "Code taken", response(400, '{"Title":"Bad Request","Detail":"Code taken"}').error_message
    assert_equal "Code taken", response(400, '{"title":"Bad Request","detail":"Code taken"}').error_message
  end

  def test_error_message_falls_back_to_the_oauth_error_description
    assert_equal "Wrong key", response(400, '{"error":"invalid_client","error_description":"Wrong key"}').error_message
  end

  def test_error_message_is_the_raw_body_when_it_isnt_json
    assert_equal "Bad gateway", response(502, "Bad gateway").error_message
  end

  def test_validation_errors_reads_the_problem_details_errors
    errors = response(400, '{"Title":"Invalid","Errors":{"VoucherDate":["Required"]}}').validation_errors

    assert_equal({"VoucherDate" => ["Required"]}, errors)
  end

  def test_a_blank_body_is_nil_data
    assert_nil response(200, " ").data
    assert_nil response(200, nil).data
  end
end
