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
  let(:eventbrite_api) { instance_double(EventbriteApiService) }

  before do
    allow(EventbriteApiService).to receive(:new).with(user).and_return(eventbrite_api)
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

  describe '#fetch_events' do
    context 'when the API request is successful' do
      let(:response) { double('Response', status: true, data: [
        { 'id' => '1', 'name' => 'Event 1', 'url' => 'url1' },
        { 'id' => '2', 'name' => 'Event 2', 'url' => 'url2' }
      ]) }

      it 'returns the events' do
        allow(eventbrite_api).to receive(:events).and_return(response)
        expect(service.fetch_events).to eq()
        expect(service.events).to eq([{ 'name' => 'Event 1' }])
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
      let(:response) { double('Response', status: true, data: [{ 'profile' => { 'email' => 'test@example.com' } }]) }

      it 'returns the attendees' do
        allow(eventbrite_api).to receive(:attendees).with(config.event_id).and_return(response)
        expect(service.fetch_attendees).to
