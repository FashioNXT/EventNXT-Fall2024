require 'oauth2'
require Rails.root.join('lib', 'constants')

# Eventbrite API wrapper.
# Currently Eventbrite does not provide an expiration time for the access token
class EventbriteApiService
  # Reponse of Evenbrite API Service.
  # status: true for succesful API calls; otherwise false.
  class Response
    attr_reader :status, :data, :error_message

    def initialize(status, data: nil, error_message: nil)
      @status = status
      @data = data
      @error_message = error_message
    end
  end

  def initialize(user)
    @user = user
    @client = OAuth2::Client.new(
      Constants::Eventbrite::CLIENT_ID,
      Constants::Eventbrite::CLIENT_SECRET,
      site: Constants::Eventbrite::API_URL,
      authorize_url: "#{Constants::Eventbrite::URL}/oauth/authorize",
      token_url: "#{Constants::Eventbrite::URL}/oauth/token"
    )
    @access_token = OAuth2::AccessToken.new(
      @client,
      @user.eventbrite_token
    )
    Rails.logger.debug("EVENTBRITE_TOKEN: #{@user.eventbrite_token}")
  end

  def organizations
    endpoint = '/users/me/organizations/'
    organizations = []
    self.each_paged_response(endpoint) do |response|
      return response unless response.status

      organizations.concat(response.data['organizations'])
    end
    Response.new(true, data: organizations)
  end

  def events
    response = self.organizations
    return response unless response.status

    organizations = response.data
    events = []

    organizations.each do |organization|
      response = self.events_of_orgainization(organization['id'])
      return response unless response.status

      events.concat(response.data)
    end

    Response.new(true, data: events)
  end

  def events_of_orgainization(organization_id)
    endpoint = "/organizations/#{organization_id}/events/"
    events = []
    self.each_paged_response(endpoint) do |response|
      return response unless response.status

      events.concat(response.data['events'].map do |event|
        { id: event['id'], name: event['name']['text'], url: event['url'] }
      end)
    end
    Response.new(true, data: events)
  end

  # Fetch a specific event
  def get_event(event_id)
    self.get("/v3/events/#{event_id}/")
  end

  # Fetch ticket classes (types) for an event
  def get_ticket_classes(event_id)
    self.get("/v3/events/#{event_id}/ticket_classes/")
  end

  # Fetch attendee data for an event
  def get_attendees(event_id)
    self.get("/v3/events/#{event_id}/attendees/")
  end

  # Fetch sales data for an event (requires special permissions)
  def get_event_sales(event_id)
    self.get("/v3/reports/events/#{event_id}/sales/")
  end

  private

  def get(endpoint, opt = {})
    # For Unknown reason omniauth2 fails to concat client.site + endpoint
    # So I expilicity set the api url here
    response = @access_token.get("#{Constants::Eventbrite::API_URL}#{endpoint}", opt:)
    data = JSON.parse(response.body)
    Rails.logger.info("Eventbrite Response Body: #{data}")
    Response.new(true, data:)
  rescue OAuth2::Error => e
    handle_oauth_error(e)
  end

  def each_paged_response(endpoint, opt = {})
    response = self.get(endpoint, opt:)
    pagination = response.data['pagination']
    yield response

    while pagination['has_more_items']
      if opt[:parameters].present?
        opt[:parameters][:continuation] = pagination['continuation']
      else
        opt[:parameters] = { continuation: pagination['continuation'] }
      end

      response = self.get(endpoint, opt)
      pagination = response.data['pagination']
      yield response
    end
    response
  end

  def handle_oauth_error(error)
    Rails.logger.debug("#API ERROR: #{error.inspect}")

    case error.response.status
    when 401
      # Unauthorized - token might be invalid or expired
      Response.new(false, error_message: 'Unauthorized access. Please reconnect your Eventbrite account.')
    else
      # Other errors
      Response.new(false, error_message: "Eventbrite API error: #{error.message}")
    end
  end
end
