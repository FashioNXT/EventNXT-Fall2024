require 'oauth2'
require Rails.root.join('lib', 'constants')

# Eventbrite API wrapper
# Currently Eventbrite does not provide an expiration time for the access token
class EventbriteApi
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
  end

  # Fetch events owned by the user
  def user_owned_event
    self.get('/v3/users/me/owned_events/')
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

  def get(endpoint)
    response = @access_token.get(endpoint)
    JSON.parse(response.body)
  rescue OAuth2::Error => e
    handle_oauth_error(e)
  end

  def handle_oauth_error(error)
    case error.response.status
    when 401
      # Unauthorized - token might be invalid or expired
      raise 'Unauthorized access. Please reconnect your Eventbrite account.'
    else
      # Other errors
      raise "Eventbrite API error: #{error.message}"
    end
  end
end
