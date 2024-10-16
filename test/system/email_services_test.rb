# frozen_string_literal: true

require 'application_system_test_case'

class EmailServicesTest < ApplicationSystemTestCase
  setup do
    @email_service = email_services(:one)
  end

  test 'visiting the index' do
    visit email_services_url
    assert_selector 'h1', text: 'Email services'
  end

  test 'should create email service' do
    visit email_services_url
    click_on 'New email service'

    fill_in 'Body', with: @email_service.body
    fill_in 'Subject', with: @email_service.subject
    fill_in 'To', with: @email_service.to
    click_on 'Create Email service'

    assert_text 'Email service was successfully created'
    click_on 'Back'
  end

  test 'should update Email service' do
    visit email_service_url(@email_service)
    click_on 'Edit this email service', match: :first

    fill_in 'Body', with: @email_service.body
    fill_in 'Subject', with: @email_service.subject
    fill_in 'To', with: @email_service.to
    click_on 'Update Email service'

    assert_text 'Email service was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Email service' do
    visit email_service_url(@email_service)
    click_on 'Destroy this email service', match: :first

    assert_text 'Email service was successfully destroyed'
  end
end
