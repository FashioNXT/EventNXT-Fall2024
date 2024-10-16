# frozen_string_literal: true

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

Then('I should be on the index page') do
  visit root_path
end

Then('I should be on the sign up page') do
  visit new_user_registration_path
end

Then('I should be on the Sign in page') do
  visit new_user_session_path
end

# Below are the referral table feature deexamplifications.

Given('we have a user') do
  @user = User.create(email: 'aaaaaaa@aaaaaaa.aaa', password: 'aaaaaaaa')
end

Given('we visit the login page') do
  visit new_user_session_path
end

Given("we enter {string} into 'Email'") do |string|
  fill_in 'Email', with: string
end

Given("we enter {string} into 'Password'") do |string|
  fill_in 'Password', with: string
end

Given("we click the 'Log in' button") do
  click_button 'Log in'
end

Given('we have an event') do
  the_event_parametrization = {
    title: 'yy',
    address: 'yyy',
    description: 'yyy',
    datetime: '04-01-2011 14:00:00 UTC'
  }
  @event = Event.create(the_event_parametrization)
  @event.save
end

Given('we have seats') do
  the_seats_parametrization = {
    category: 'category1',
    total_count: 80,
    event_id: 1,
    section: 1
  }
  @seat = Seat.create(the_seats_parametrization)
  @seat.save
end

Given('we have guests') do
  the_guest_parametrization = {
    first_name: 'xx',
    last_name: 'xx',
    email: 'yyyyyyy@yyyyyyy.yyy',
    affiliation: 'xx',
    category: 'category1',
    alloted_seats: 1,
    commited_seats: 1,
    guest_commited: 1,
    event_id: 1,
    section: 1
  }
  @guest = Guest.create(the_guest_parametrization)
  @guest.save
end

When('we visit the new page for the referral') do
  visit new_referral_path(random_code: @guest.rsvp_link)
end

When("we enter {string} into 'Friend's Email Address'") do |string|
  fill_in "Friend's Email Address", with: string
end

When('we click the {string}') do |string|
  click_button(string)
end

Then('there will be one additional referral tuple generated with expected attibute on the referee email with {string}') do |string|
  expect(Referral.last.referred).to match(string)
end

When('we have a referral with 5 tickets bought') do
  the_referral_parametrization = {
    email: @guest.email,
    name: @guest.first_name + ' ' + @guest.last_name,
    referred: 'aaaaaaa@aaaaaaa.aaa',
    status: true,
    tickets: 5,
    amount: 150,
    reward_method: 'reward/ticket',
    reward_input: 0,
    reward_value: 0,
    guest_id: @guest.id,
    event_id: @event.id,
    ref_code: @guest.id
  }
  @referral = Referral.create(the_referral_parametrization)
  @referral.save
end

When('we visit the show page for this event') do
  visit event_path(@event)
end

When('visit the edit referral page') do
  visit edit_event_referral_path(event_id: @event.id, id: @referral.id)
end

When("we enter 10 into 'Input'") do
  fill_in 'Input', with: 10
end

When('we click submit') do
  click_button 'Submit'
end

Then('the reward value will be updated to 50') do
  @referral.reload
  expect(@referral.reward_value).to eq(50)
end
