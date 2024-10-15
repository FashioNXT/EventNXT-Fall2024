Then('I should be on the event dashboard page') do
  expect(page).to have_current_path(events_path, ignore_query: true)
end

When('I click on the {string} button') do |string|
  click_on(string)
end

When('I should see Edit User') do
  expect(page).to have_content('Edit User')
end
