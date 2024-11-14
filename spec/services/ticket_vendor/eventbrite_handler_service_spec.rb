require 'rails_helper'

RSpec.describe TicketVendor::EventbriteHandlerService do
  let(:user) { create(:user, Constants::Eventbrite::SYM) }
  let(:config) do
    OpenStruct.new(
      event_id: '12345',
      category_source_key: 'ticket_class_name',
      section_source_key: 'ticket_class_name',
      tickets_source_key: 'quantity',
      cost_source_key: 'costs.base_price'
    )
  end
  let(:service) { described_class.new(user, config) }
  let(:eventbrite_api) { instance_double(TicketVendor::EventbriteApiService) }

  before do
    allow(TicketVendor::EventbriteApiService).to receive(:new).with(user).and_return(eventbrite_api)
  end

  describe '#authorized?' do
    it 'returns true if the user has an eventbrite token' do
      expect(service.authorized?).to be true
    end

    it 'returns false if the user does not have an eventbrite token' do
      allow(user).to receive(:eventbrite_token).and_return(nil)
      expect(service.authorized?).to be false
    end
  end

  describe '#disonnect' do
    it 'delete eventbrite_token from the current user' do
      service.disconnect
      expect(user.eventbrite_token).to be nil
    end
  end

  describe '#compose_ticket_sales' do
    let(:attendees) do
      [
        { 
          'profile' => { 'email' => 'user1@example.com' },
          'ticket_class_name' => 'fake_ticket_1',
          'quantity'=> 1,
          'costs' => { 'base_price' => {'display' => '$10.0'} } 
        },
        { 
          'profile' => { 'email' => 'user2@example.com' },
          'ticket_class_name' => 'fake_ticket_2',
          'quantity' => 1,
          'costs' => { 'base_price' => {'display' => '$20'} } 
        }
      ]
    end

    it 'compiles ticket sales data from attendees' do
      allow(service).to receive(:fetch_attendees).and_return(attendees)
      expected_ticket_sales = [
        { email: 'user1@example.com', category: 'fake_ticket_1', section: 'fake_ticket_1', tickets: 1, cost: 10 },
        { email: 'user2@example.com', category: 'fake_ticket_2', section: 'fake_ticket_2', tickets: 1, cost: 20 }
      ]

      expect(service.compose_ticket_sales).to eq(expected_ticket_sales)
      expect(service.ticket_sales).to eq(expected_ticket_sales)
    end
  end

  describe '#fetch_events' do
    context 'when the API request is successful' do
      let(:response) { double('Response', status: true, data: [
        { 'id' => '1', 'name' => { 'text' => 'Event 1' }, 'url' => 'url1', 'other' => 'other' },
        { 'id' => '2', 'name' => { 'text' => 'Event 2' }, 'url' => 'url2', 'other' => 'other' }
      ]) }

      expected = [
        { id: '1', name: 'Event 1', url: 'url1' },
        { id: '2', name: 'Event 2', url: 'url2' } 
      ]

      it 'returns the events' do
        allow(eventbrite_api).to receive(:events).and_return(response)
        expect(service.fetch_events).to eq(expected)
        expect(service.events).to eq(expected)
      end
    end

    context 'when the API request fails' do
      let(:response) { double('Response', status: false, error_message: 'Error fetching events') }

      it 'sets the error message and returns an empty array' do
        allow(eventbrite_api).to receive(:events).and_return(response)
        expect(service.fetch_events).to eq([])
        expect(service.error_message).to eq('Error fetching events')
      end
    end
  end

  describe '#fetch_attendees' do
    context 'when the API request is successful' do
      let(:response) { double('Response', status: true, data: [
        { 
          'profile' => { 'email' => 'user1@example.com' },
          'ticket_class_name' => 'fake_ticket',
          'quantity': 1,
          'costs' => { 'base_price' => {'display' => '$10.0'} } 
        },
        { 
          'profile' => { 'email' => 'user2@example.com' },
          'ticket_class_name' => 'fake_ticket',
          'quantity': 1,
          'costs' => { 'base_price' => {'display' => '$20'} } 
        }
      ]) }

      it 'returns the attendees' do
        allow(eventbrite_api).to receive(:attendees).with(config.event_id).and_return(response)
        expect(service.fetch_attendees).to eq(response.data)
        expect(service.instance_variable_get(:@attendees)).to eq(response.data)
      end
    end
    
    context 'when the API request fails' do
      let(:response) { double('Response', status: false, error_message: 'Error fetching attendees') }

      it 'sets the error message and returns an empty array' do
        allow(eventbrite_api).to receive(:attendees).with(config.event_id).and_return(response)
        expect(service.fetch_attendees).to eq([])
        expect(service.error_message).to eq('Error fetching attendees')
      end
    end
  end
end
