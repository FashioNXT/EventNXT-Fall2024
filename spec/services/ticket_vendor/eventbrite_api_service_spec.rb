require 'rails_helper'

RSpec.describe TicketVendor::EventbriteApiService do
  let(:user) { create(:user, Constants::Eventbrite::SYM) }
  let(:mock_client) { instance_double(OAuth2::Client) }
  let(:mock_access_token) { instance_double(OAuth2::AccessToken) }
  let(:service) { described_class.new(user) }

  before do
    allow(OAuth2::Client).to receive(:new).and_return(mock_client)
    allow(OAuth2::AccessToken).to receive(:new).with(mock_client, user.eventbrite_token).and_return(mock_access_token)
  end

  describe '#initialize' do
    it 'initializes with user and OAuth2 client' do
      expect(service.instance_variable_get(:@user)).to eq(user)
      expect(service.instance_variable_get(:@client)).to eq(mock_client)
      expect(service.instance_variable_get(:@access_token)).to eq(mock_access_token)
    end
  end

  describe '#organizations' do
    let(:response_body1) {{
      'organizations' => [{ 'id' => 'org_1' }, { 'id' => 'org_2' }],
      'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
    }}
    let(:response_body2) {{
      'organizations' => [{ 'id' => 'org_3' }, { 'id' => 'org_4' }],
      'pagination' => { 'has_more_items' => false } 
    }}
    

    it 'returns a list of organizations' do
      allow(service).to receive(:get)
        .with('/users/me/organizations/', opt: {})
        .and_return(
          TicketVendor::EventbriteApiService::Response.new(true, data: response_body1)
        )
      allow(service).to receive(:get)
        .with('/users/me/organizations/', opt: { parameters: { continuation: 'token1' } })
        .and_return(
          TicketVendor::EventbriteApiService::Response.new(true, data: response_body2)
        )

      result = service.organizations
      expect(result.status).to be true
      expect(result.data).to eq(
        response_body1['organizations'].concat(response_body2['organizations'])
      )
    end
  end

  describe '#events' do
    let(:org_response) { 
      TicketVendor::EventbriteApiService::Response.new(true, data: [
        { 'id' => 'org_1' }, 
        { 'id' => 'org_2' }
      ]) 
    }
    let(:events_response1) { 
      TicketVendor::EventbriteApiService::Response.new(true, data: [
        { 'id' => 'event_1', 'name' => { 'text' => 'Event 1' }, 'url' => 'fake_url' },
        { 'id' => 'event_2', 'name' => { 'text' => 'Event 2' }, 'url' => 'fake_url2' }
      ])
    }
    let(:events_response2) { 
      TicketVendor::EventbriteApiService::Response.new(true, data: [
        { 'id' => 'event_3', 'name' => { 'text' => 'Event 3' }, 'url' => 'fake_url3' },
        { 'id' => 'event_4', 'name' => { 'text' => 'Event 4' }, 'url' => 'fake_url4' }
      ])
    }

    it 'fetches events from organizations' do
      allow(service).to receive(:organizations).and_return(org_response)
      allow(service).to receive(:events_of_orgainization).with('org_1').and_return(events_response1)
      allow(service).to receive(:events_of_orgainization).with('org_2').and_return(events_response2)
      

      result = service.events
      expect(result.status).to be true
      expect(result.data).to eq(
        events_response1.data.concat(events_response2.data)
      )
    end
  end

  describe '#events_of_organization' do
    let(:org_id) { 'fake_id' }
    let(:response_body1) {{
      'events' => [{ 'id' => 'event_1' },  { 'id' => 'event_2' }],
      'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
    }}
    let(:response_body2) {{
      'events' => [{ 'id' => 'event_3' },  { 'id' => 'event_4' }],
      'pagination' => { 'has_more_items' => false }
    }}
  

    it 'returns a list of events' do
      allow(service).to receive(:get)
        .with("/organizations/#{org_id}/events/", opt: {})
        .and_return(
          TicketVendor::EventbriteApiService::Response.new(true, data: response_body1)
        )
      allow(service).to receive(:get)
        .with("/organizations/#{org_id}/events/", opt: { parameters: { continuation: 'token1' } })
        .and_return(
          TicketVendor::EventbriteApiService::Response.new(true, data: response_body2)
        )

      result = service.events_of_orgainization(org_id)
      expect(result.status).to be true
      expect(result.data).to eq(
        response_body1['events'].concat(response_body2['events'])
      )
    end
  end

  describe '#attendees' do
    let(:event_id) { 'fake_id' } 
    let(:response_body1) {{
      'attendees' => [{ 'id' => 'attendee_1' },  { 'id' => 'attendee_2' }],
      'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
    }}
    let(:response_body2) {{
      'attendees' => [{ 'id' => 'attendee_3' },  { 'id' => 'attendee_4' }],
      'pagination' => { 'has_more_items' => false }
    }}
  

    it 'returns attendees for an event' do
      allow(service).to receive(:get)
      .with("/events/#{event_id}/attendees/", opt: {})
      .and_return(
        TicketVendor::EventbriteApiService::Response.new(true, data: response_body1)
      )
      allow(service).to receive(:get)
      .with("/events/#{event_id}/attendees/", opt: { parameters: { continuation: 'token1' } })
      .and_return(
        TicketVendor::EventbriteApiService::Response.new(true, data: response_body2)
      )

      result = service.attendees(event_id)
      expect(result.status).to be true
      expect(result.data).to eq(
        response_body1['attendees'].concat(response_body2['attendees'])
      )
    end
  end

  describe 'error handling' do
    let(:error_response1) { double('ErrorResponse', status: 401, message: 'Unauthorized') }
    let(:error_response2) { double('ErrorResponse', status: 404, message: 'Resource not found') }

    before do
      allow(mock_access_token).to receive(:get).and_raise(OAuth2::Error.new(error_response1))
      allow(mock_access_token).to receive(:get).and_raise(OAuth2::Error.new(error_response2))
    end

    it 'handles OAuth2 errors with unauthorized status' do
      result = service.send(:handle_oauth_error, OAuth2::Error.new(error_response1))
      expect(result.status).to be false
      expect(result.error_message).to eq('Unauthorized access. Please reconnect your Eventbrite account.')
    end

    it 'handles other OAuth2 errors' do
      result = service.send(:handle_oauth_error, OAuth2::Error.new(error_response2))
      expect(result.status).to be false
      expect(result.error_message).to start_with('Eventbrite API error: ')
    end
  end
end
