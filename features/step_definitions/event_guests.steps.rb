Then('I should see {string} in the guest list') do |string|
  expect(page).to have_content(string)
end

# | first_name | last_name | email | affiliation | category | section
# | alloted_seats | commited_seats | guest_commited |
Given('I have the following guests') do |table|
  table.hashes.each do |seat|
    @event.guests.create(seat)
  end
  @guest = @event.guests.first
end
