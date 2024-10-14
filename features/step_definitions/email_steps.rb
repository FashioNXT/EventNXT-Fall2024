# Given('I am logged in as {string}') do |email|
#   @user = User.find_by(email: email) || User.create(email: email, password: 'password123')
#   visit new_user_session_path
#   fill_in 'Email', with: @user.email
#   fill_in 'Password', with: 'password123'
#   click_button 'Log in'
# end
Given('I am on the Email services page') do
  # path = email_services_path
  # puts "Navigating to: #{path}"
  visit email_services_path
  # puts page.body
  # You may need to adjust the path if your email service page has a different URL
end

When('I click on {string} button') do |button_text|
  # puts page.body
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
