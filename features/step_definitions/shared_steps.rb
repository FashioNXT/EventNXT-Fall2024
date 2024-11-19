Given('I am on the index page') do
  visit root_path
end

Then('I should be on the index page') do
  visit root_path
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click on {string}') do |text|
  click_on text
end

When('I select {string} from the dropdown {string}') do |value, dropdown|
  select value, from: dropdown
end

When("I select {string} from the dropdown labeled {string}") do |option, label|
  find('label', text: label).sibling('select').find('option', text: option).select_option
end

When('I check the box {string}') do |text|
  check text
end

When('I attach the file {string} to the field {string}') do |file_name, field|
  file_path = Rails.root.join('spec', 'fixtures', 'files', file_name)
  attach_file field, file_path
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should not see {string}') do |message|
  expect(page).not_to have_content(message)
end

When('I click on the {string} button') do |button_text|
  click_button(button_text)
end

Then('I should see {string} in the error messages') do |message|
  expect(page).to have_text(/#{Regexp.escape(message)}/)
end