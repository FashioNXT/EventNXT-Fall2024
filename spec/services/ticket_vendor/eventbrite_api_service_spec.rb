require 'rails_helper'

def mock_pagination_responses(service, endpoint, response_bodies)
  continuation = nil
  response_bodies.each do |response_body|
    response =  TicketVendor::EventbriteApiService::Response.new(true, data: response_body)
    opts = continuation.present? ? { parameters: { continuation: } } : {}
    continuation = response_body['pagination']['continuation']

    allow(service).to receive(:get).with(endpoint, opts:).and_return(response)       
  end
end

RSpec.describe TicketVendor::EventbriteApiService do
  let(:user) { create(:user, Constants::Eventbrite::SYM) }
  let(:client) { instance_double(OAuth2::Client) }
  let(:access_token) { instance_double(OAuth2::AccessToken) }
  let(:service) { described_class.new(user) }

  before do
    allow(OAuth2::Client).to receive(:new).and_return(client)
    allow(OAuth2::AccessToken).to receive(:new)
      .with(client, user.eventbrite_token)
      .and_return(access_token)
  end

  describe '#organizations' do
    let(:endpoint) { '/users/me/organizations/' }

    let(:response_bodies) do
      [
        {
          'organizations' => [{ 'id' => 'org_1' }, { 'id' => 'org_2' }],
          'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
        },
        {
          'organizations' => [{ 'id' => 'org_3' }, { 'id' => 'org_4' }],
          'pagination' => { 'has_more_items' => false } 
        }
      ]
    end

    let(:expected_data) do
      response_bodies.flat_map { |response_body| response_body['organizations'] }
    end

    before do
      mock_pagination_responses(service, endpoint, response_bodies)
    end

    it 'returns a list of organizations' do
      result = service.organizations
      expect(result.status).to be true
      expect(result.data).to eq(expected_data)
    end
  end

  describe '#events' do
    let(:orgs_response) do
      TicketVendor::EventbriteApiService::Response.new(true, data: [
        { 'id' => 'org_1' }, 
        { 'id' => 'org_2' }
      ]) 
    end

    let(:events_responses) do
      [
        TicketVendor::EventbriteApiService::Response.new(true, data: [
          { 'id' => 'event_1', 'name' => { 'text' => 'Event 1' }, 'url' => 'fake_url' },
          { 'id' => 'event_2', 'name' => { 'text' => 'Event 2' }, 'url' => 'fake_url2' }
        ]),
        TicketVendor::EventbriteApiService::Response.new(true, data: [
          { 'id' => 'event_3', 'name' => { 'text' => 'Event 3' }, 'url' => 'fake_url3' },
          { 'id' => 'event_4', 'name' => { 'text' => 'Event 4' }, 'url' => 'fake_url4' }
        ])
      ]
    end

    let(:expected_data) do
      events_responses.flat_map { |response| response.data }
    end
     
    before do
      allow(service).to receive(:organizations).and_return(orgs_response)

      orgs_response.data.each_with_index do |org, idx|
        allow(service).to receive(:events_of_orgainization)
          .with(org['id'])
          .and_return(events_responses[idx])
      end
    end

    it 'fetches events from organizations' do
      result = service.events
      expect(result.status).to be true
      expect(result.data).to eq(expected_data)
    end
  end

  describe '#events_of_organization' do
    let(:org_id) { 'fake_id' }
    let(:endpoint) { "/organizations/#{org_id}/events/" }
   
    let(:response_bodies) do
      [
        {
          'events' => [{ 'id' => 'event_1' },  { 'id' => 'event_2' }],
          'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
        },
        {
          'events' => [{ 'id' => 'event_3' },  { 'id' => 'event_4' }],
          'pagination' => { 'has_more_items' => false }
        }
      ]
    end

    let(:expected_data) do
      response_bodies.flat_map { |response_body| response_body['events'] }
    end

    before do
      mock_pagination_responses(service, endpoint, response_bodies)
    end

    it 'returns a list of events' do
      result = service.events_of_orgainization(org_id)
      expect(result.status).to be true
      expect(result.data).to eq(expected_data)
    end
  end

  describe '#attendees' do
    let(:event_id) { 'fake_id' } 
    let(:endpoint) { "/events/#{event_id}/attendees/" }
   
    let(:response_bodies) do
      [
        {
          'attendees' => [{ 'id' => 'attendee_1' },  { 'id' => 'attendee_2' }],
          'pagination' => { 'has_more_items' => true, 'continuation' => 'token1' }
        },
        {
          'attendees' => [{ 'id' => 'attendee_3' },  { 'id' => 'attendee_4' }],
          'pagination' => { 'has_more_items' => false }
        }
      ]
    end

    let(:expected_data) do
      response_bodies.flat_map { |response_body| response_body['attendees'] }
    end

    before do
      mock_pagination_responses(service, endpoint, response_bodies)
    end

    it 'returns attendees for an event' do
      result = service.attendees(event_id)
      expect(result.status).to be true
      expect(result.data).to eq(expected_data)
    end
  end

  describe '#get' do
    let(:endpoint) { '/resource/endpoint' }
    let(:full_url) { "#{Constants::Eventbrite::API_URL}#{endpoint}" }
    let(:opts) { { params: { param1: 'value' } } }
    let(:response_body) do
      {
        'field' => ['item1' ,'item2'], 
        'field2' => 20 
      }
    end
    let(:response) { OpenStruct.new(body: response_body.to_json) }
    
    before do
      allow(access_token).to receive(:get)
        .with(full_url, opts)
        .and_return(response)
    end
    
    context 'Success Api call' do
      it 'get response data' do
        result = service.get(endpoint, opts:)
        expect(access_token).to have_received(:get).with(full_url, opts)
        expect(result).to have_attributes(status: true, data: response_body, error_message: nil)
      end
    end

    context 'error handling' do
      let(:error_responses) do 
        [
          instance_double("OAuth2::Response", status: 401, body: {
              "error" => "Unauthorized",
              "error_description" => "The provided authorization grant is invalid, expired, or revoked."
            }.to_json
          ),
          instance_double("OAuth2::Response", status: 404, body: {
              "error" => "Resource not found",
              "error_description" => "The path does not exist."
            }.to_json
          ), 
        ]
      end
      let(:errors) { error_responses.map { |e| OAuth2::Error.new(e) } }
  
      it 'handles OAuth2 errors with unauthorized status' do
        allow(access_token).to receive(:get).and_raise(errors[0])

        result = service.get(endpoint)
        expect(result.status).to be false
        expect(result.error_message).to eq('Unauthorized access. Please reconnect your Eventbrite account.')
      end
  
      it 'handles other OAuth2 errors' do
        allow(access_token).to receive(:get).and_raise(errors[1])
        result = service.get(endpoint)
        expect(result.status).to be false
        expect(result.error_message).to start_with('Eventbrite API error:')
      end
    end
  end
end
