When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click on {string}') do |text|
  click_on text
end

When('I select {string} from the dropdown {string}') do |value, dropdown|
  select value, from: dropdown
end

When('I check the box {string}') do |text|
  check text
end

When('I attach the file {string} to the field {string}') do |file_name, field|
  file_path = Rails.root.join('spec', 'fixtures', 'files', file_name)
  attach_file field, file_path
end
