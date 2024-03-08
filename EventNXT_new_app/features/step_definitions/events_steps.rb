Given('the following users exist:') do |table|
    table.hashes.each do |user|
    User.create user
  end
end

Given('I am on the index page') do
  visit root_path
end

When('I follow {string}') do |string|
  visit new_user_registration_path 
end

Then('I should be on the Sign up page') do
  visit new_user_registration_path
end

When('I fill the {string} as {string}') do |string, string2|
  fill_in(string, with: string2)
end

When('I press {string}') do |string|
  click_button(string)
end

Then('I should be on the index page') do
  visit root_path
end

Then('I should be on the sign up page') do
  visit new_user_registration_path
end

Then('I should be on the Sign in page') do
  visit new_user_session_path
end


When('post the function import previous guest information') do
  post '/import_previous_guest_information'
end

