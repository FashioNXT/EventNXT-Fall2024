Then('I should see {string} in the guest list') do |string|
  expect(page).to have_content(string)
end
