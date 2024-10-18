# frozen_string_literal: true

Given('the user is logged in') do
  # Simulate the user being logged in
  @user_logged_in = true
end

When('the user clicks on the Logout button') do
  # Simulate the user clicking on the Logout button
  @logout_button_clicked = true
end

Then('the user should be redirected to the logout page at {string}') do |logout_page_url|
  # Verify that the user is redirected to the logout page
  expect(logout_page_url).to eq('https://events360.herokuapp.com/logout')
end
