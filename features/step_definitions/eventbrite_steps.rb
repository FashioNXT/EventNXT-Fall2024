Given('I am on the event page {string} with ticket source from Eventbrite') do |event_title|
  @event = Event.find_by(user_id: @user.id, title: title)
  if @event.nil?
    @event = FactoryBot.create(:event, 
      title: event_title, user: @user, ticket_source: Constants::TicketSales::Source::EVENTBRITE
    )
  end
  visit event_path(@event)
end

Given('I have the following Eventbrite Events') do |table|
  api_service = instance_double(TicketVendor::EventbriteApiService)
  allow(TicketVendor::EventbriteApiService).to receive(:new).and_return(api_service)
  allow(api_service).to receive(:events).and_return(
    TicketVendor::EventbriteApiService::Response.new(true,
      data: table.hashes.map { |row| { 'id' => row[:id], 'name' => { 'text' => row[:name] } } }
    )
  )
end

Then('I should see the external events list showing {string}') do |options|
  expected_options = options.split(', ').map(&:strip)
  dropdown = find_by_id('ticket-sales-select')
  dropdown_options = dropdown.all('option').map(&:text)

  expected_options.each do |option|
    expect(dropdown_options).to include(option)
  end  
end