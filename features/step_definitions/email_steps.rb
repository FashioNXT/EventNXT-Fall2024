Given("I am on the Email service page") do
  visit email_services_path
  # You may need to adjust the path if your email service page has a different URL
end

When("I click on {string} button") do |button_text|
  click_on button_text
end

Given('I am on the confirmation page of a created email service') do
  # Implement steps to navigate to the confirmation page
  # This could involve visiting a URL directly or performing actions to create an email service
  visit '/refer_a_friend'
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

Given('I am on the purchase tickets page of a created email service') do
  # Implement steps to navigate to the confirmation page
  # This could involve visiting a URL directly or performing actions to create an email service
  visit '/tickets/new' 
end