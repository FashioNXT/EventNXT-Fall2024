# frozen_string_literal: true

Given('I am on the events dashboard') do
  visit events_path(@user)
end

Given('I am on the event page {string}') do |event_title|
  @event = Event.find_by(user_id: @user.id, title: title)
  if @event.nil?
    @event = FactoryBot.create(:event, title: event_title, user: @user)
  end
  visit event_path(@event)
end

# Below are the legacy step definitons for referal table featur
When('we visit the new page for the referral') do
  visit new_referral_path(random_code: @guest.rsvp_link)
end

When("we enter {string} into the 'friend_emails' field") do |input|
  fill_in 'friend_emails', with: input
end

When('we click the {string}') do |button_text|
  click_button(button_text)
end

Then('there will be one additional referral tuple generated with expected attibute on the referee email with {string}') do |string|
  puts(Referral.all.length)
  expect(Referral.last.referred).to match(string)
end

When('we have a referral with 5 tickets bought') do
  the_referral_parametrization = {
    email: @guest.email,
    name: "#{@guest.first_name} #{@guest.last_name}",
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
