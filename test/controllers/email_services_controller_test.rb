require "test_helper"

class EmailServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email_service = email_services(:one)
  end

  test "should get index" do
    get email_services_url
    assert_response :success
  end

  test "should get new" do
    get new_email_service_url
    assert_response :success
  end

  test "should create email_service" do
    assert_difference("EmailService.count") do
      post email_services_url, params: { email_service: { body: @email_service.body, subject: @email_service.subject, to: @email_service.to } }
    end

    assert_redirected_to email_service_url(EmailService.last)
  end

  test "should show email_service" do
    get email_service_url(@email_service)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_service_url(@email_service)
    assert_response :success
  end

  test "should update email_service" do
    patch email_service_url(@email_service), params: { email_service: { body: @email_service.body, subject: @email_service.subject, to: @email_service.to } }
    assert_redirected_to email_service_url(@email_service)
  end

  test "should destroy email_service" do
    assert_difference("EmailService.count", -1) do
      delete email_service_url(@email_service)
    end

    assert_redirected_to email_services_url
  end
end
