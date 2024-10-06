Given('I am on the event page {string}') do |event_title|
  @user = FactoryBot.create(:user)
  @event = FactoryBot.create(:event, title: event_title, user: @user)

  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Log in'

  visit event_path(@event)
end

Then('I add the following seats for the event {string}') do |event_title, table|
  @event = Event.find_by(title: event_title)
  table.hashes.each do |seat|
    @event.seats.create(seat)
  end
end
