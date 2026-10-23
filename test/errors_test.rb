require_relative "test_helper"

class PowerOffice::ErrorsTest < Minitest::Test
  include PowerOfficeTestHelpers

  def test_from_maps_statuses_to_error_classes
    {
      400 => PowerOffice::Errors::ValidationError,
      401 => PowerOffice::Errors::AuthenticationError,
      403 => PowerOffice::Errors::ForbiddenError,
      404 => PowerOffice::Errors::NotFoundError,
      429 => PowerOffice::Errors::RateLimitError,
      503 => PowerOffice::Errors::ServerError,
      409 => PowerOffice::Errors::Error
    }.each do |status, error_class|
      error = PowerOffice::Errors.from(response(status, '{"Title":"Nope"}'))

      assert_instance_of error_class, error
      assert_equal status, error.code
      assert_equal "Nope", error.message
    end
  end

  def test_from_falls_back_to_the_status_when_the_body_has_no_message
    assert_equal "HTTP 403", PowerOffice::Errors.from(response(403, "")).message
  end

  def test_a_validation_error_carries_the_field_errors
    invalid = response(400, '{"Title":"Invalid","Errors":{"VoucherDate":["Required"]}}')

    assert_equal({"VoucherDate" => ["Required"]}, PowerOffice::Errors.from(invalid).errors)
  end
end
