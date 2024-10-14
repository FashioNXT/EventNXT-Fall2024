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

# Given('we have an event') do
#   the_event_parametrization = {
#     title: 'yy',
#     address: 'yyy',
#     description: 'yyy',
#     datetime: '04-01-2011 14:00:00 UTC'
#   }
#   @event = Event.create(the_event_parametrization)
#   @event.save
# end

Given('we have an event') do
  # Use the existing @user from 'Given we have a user'
  @event = Event.create(
    title: 'yy',
    address: 'yyy',
    description: 'yyy',
    datetime: '04-01-2011 14:00:00 UTC',
    user_id: @user.id # Associate with the existing User
  )

  # Check if the Event is created successfully
  if @event.persisted?
    puts "Event created successfully with ID: #{@event.id}"
  else
    puts "Event not saved: #{@event.errors.full_messages.join(", ")}"
  end
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
Given('I am logged in as {string}') do |email|
  @user = User.find_by(email: email) || User.create(email: email, password: 'password123')
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password123'
  click_button 'Log in'
end
# Given('we have guests') do
#   the_guest_parametrization = {
#     first_name: 'xx',
#     last_name: 'xx',
#     email: 'yyyyyyy@yyyyyyy.yyy',
#     rsvp_link: 'test_random_code', # Set a specific rsvp_link value here
#     affiliation: 'xx',
#     category: 'category1',
#     alloted_seats: 1,
#     commited_seats: 1,
#     guest_commited: 1,
#     event_id: @event.id,
#     section: 1
#   }
#   @guest = Guest.create(the_guest_parametrization)
#   @guest.save
# end

Given('we have guests') do
  @guest = Guest.create(
    first_name: 'xx',
    last_name: 'xx',
    email: 'yyyyyyy@yyyyyyy.yyy',
    rsvp_link: 'test_random_code', # Matches the URL parameter in the test scenario
    affiliation: 'xx',
    category: 'category1',
    alloted_seats: 1,
    commited_seats: 1,
    guest_commited: 1,
    event_id:@event.id, # Uses the existing event created in the test
    section: 1
  )
  if @guest.persisted?
    @rsvp_link = @guest.rsvp_link
    # puts "Guest created successfully."
  # else
    # puts "Guest not saved: #{@guest.errors.full_messages.join(", ")}"
  end 
end
When('we visit the new page for the referral') do
  # puts new_referral_path(random_code: @rsvp_link)
  visit new_referral_path(random_code: @rsvp_link)
  # puts page.body
end
When("we enter {string} into 'Friend's Email Address'") do |string|
  # puts page.body
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