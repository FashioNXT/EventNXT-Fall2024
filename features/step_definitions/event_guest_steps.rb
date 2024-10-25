Then('I should see {string} in the guest list') do |string|
  expect(page).to have_content(string)
end

Then('I should see {string} in the error messages') do |message|
  expect(page).to have_text(/#{Regexp.escape(message)}/)
end