# features/step_definitions/email_steps.rb
include EmailServicesHelper  # Include the helper module here

Given('I have an email with subject {string}') do |subject|
  @subject = subject
  @body = 'Original Body'
end

When('I render the email template') do
  @result = render_template_with_generic_placeholders(subject: @subject, body: @body)
end

Then('the output should contain {string}') do |content|
  expect(@result).to include(content)
end

Given('I am on the Email service page') do
  visit email_services_path
  # You may need to adjust the path if your email service page has a different URL
end

When('I click on {string} button') do |button_text|
  click_on button_text
end

Given('I am on the confirmation page of a created email service') do
  # Implement steps to navigate to the confirmation page
  # This could involve visiting a URL directly or performing actions to create an email service
  visit '/refer_a_friend'
end

Given('I am on the purchase tickets page of a created email service') do
  # Implement steps to navigate to the confirmation page
  # This could involve visiting a URL directly or performing actions to create an email service
  visit '/tickets/new'
end
