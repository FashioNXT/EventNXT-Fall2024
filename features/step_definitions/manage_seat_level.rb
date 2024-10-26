# # frozen_string_literal: true

# Given('I am on the events dashboard') do
#     visit events_path(@user)
#   end
  
#   Given('I am on the event page {string}') do |event_title|
#     @event = FactoryBot.create(:event, title: event_title, user: @user)
#     visit event_path(@event)
#   end
  
#   # Below are the legacy step definitons for referal table featur
#   When('we visit the new page for the referral') do
#     visit new_referral_path(random_code: @guest.rsvp_link)
#   end
  
#   When("we enter {string} into 'Friend's Email Address'") do |string|
#     fill_in "Friend's Email Address", with: string
#   end
  
#   When('we click the {string}') do |string|
#     click_button(string)
#   end
  
#   Then('there will be one additional referral tuple generated with expected attibute on the referee email with {string}') do |string|
#     expect(Referral.last.referred).to match(string)
#   end
  
#   When('we have a referral with 5 tickets bought') do
#     the_referral_parametrization = {
#       email: @guest.email,
#       name: "#{@guest.first_name} #{@guest.last_name}",
#       referred: 'aaaaaaa@aaaaaaa.aaa',
#       status: true,
#       tickets: 5,
#       amount: 150,
#       reward_method: 'reward/ticket',
#       reward_input: 0,
#       reward_value: 0,
#       guest_id: @guest.id,
#       event_id: @event.id,
#       ref_code: @guest.id
#     }
#     @referral = Referral.create(the_referral_parametrization)
#     @referral.save
#   end
  
#   When('we visit the show page for this event') do
#     visit event_path(@event)
#   end
  
#   When('visit the edit referral page') do
#     visit edit_event_referral_path(event_id: @event.id, id: @referral.id)
#   end
  
#   When("we enter 10 into 'Input'") do
#     fill_in 'Input', with: 10
#   end
  
#   When('we click submit') do
#     click_button 'Submit'
#   end
  
#   Then('the reward value will be updated to 50') do
#     @referral.reload
#     expect(@referral.reward_value).to eq(50)
#   end
  
#   ###################

#   Then('I should see {string} in the guest list') do |string|
#     expect(page).to have_content(string)
#   end

#   Then('I should see {string} in the seat list') do |string|
#     expect(page).to have_content(string)
#   end
  
#   # | first_name | last_name | email | affiliation | category | section
#   # | alloted_seats | commited_seats | guest_commited |
#   Given('I have the following guests') do |table|
#     table.hashes.each do |seat|
#       @event.guests.create(seat)
#     end
#     @guest = @event.guests.first
#   end
  
#   ######################
#   Given('I have the following seats') do |table|
#     table.hashes.each do |seat|
#       @event.seats.create(seat)
#     end
#   end

  
#   ########################

#   Given('I am on the index page') do
#     visit root_path
#   end
  
#   Then('I should be on the index page') do
#     visit root_path
#   end
  
#   When('I fill in {string} with {string}') do |field, value|
#     fill_in field, with: value
#   end
  
#   When('I click on {string}') do |text|
#     click_on text
#   end
  
#   When('I select {string} from the dropdown {string}') do |value, dropdown|
#     select value, from: dropdown
#   end
  
#   When('I check the box {string}') do |text|
#     check text
#   end
  
#   When('I attach the file {string} to the field {string}') do |file_name, field|
#     file_path = Rails.root.join('spec', 'fixtures', 'files', file_name)
#     attach_file field, file_path
#   end
  
#   Then('I should see {string}') do |message|
#     expect(page).to have_content(message)
#   end
  
#   Then('I should not see {string}') do |message|
#     expect(page).not_to have_content(message)
#   end
  