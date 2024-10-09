Given('The following users exist:') do |table|
  table.hashes.each do |user|
    User.create user
  end
end

Given('I am on the login page') do
  visit new_user_session_path
end

Given('I sign in with email {string} and password {string}') do |email, password|
  visit new_user_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log in'
end
