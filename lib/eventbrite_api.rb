require 'oauth2'

# Eventbrite API wrapper
class EventbriteApi
  BASE_URL = ENV['EVENTBRITE_URL'] || 'https://www.eventbrite.com'
  API_URL = ENV['EVENTBRITE_API_URL'] || 'https://www.eventbriteapi.com/v3'

  def initialize(user)
    @user = user
    @client = OAuth2::Client.new(
      ENV['EVENTBRITE_CLIENT_ID'],
      ENV['EVENTBRITE_CLIENT_SECRET'],
      site: API_URL,
      authorize_url: "#{BASE_URL}/oauth/authorize",
      token_url: "#{BASE_URL}/oauth/token"
    )
    @access_token = OAuth2::AccessToken.new(
      @client,
      @user.eventbrite_token,
      refresh_token: @user.eventbrite_refresh_token,
      expires_at: @user.eventbrite_token_expires_at.to_i
    )
  end

  # Fetch events owned by the user
  def user_owned_events
    self.refresh_token_if_needed!
    self.get('/v3/users/me/owned_events/')
  end

  # Fetch a specific event
  def get_event(event_id)
    self.refresh_token_if_needed!
    self.get("/v3/events/#{event_id}/")
  end

  # Fetch ticket classes (types) for an event
  def get_ticket_classes(event_id)
    self.refresh_token_if_needed!
    self.get("/v3/events/#{event_id}/ticket_classes/")
  end

  # Fetch attendee data for an event
  def get_attendees(event_id)
    self.refresh_token_if_needed!
    self.get("/v3/events/#{event_id}/attendees/")
  end

  # Fetch sales data for an event (requires special permissions)
  def get_event_sales(event_id)
    self.refresh_token_if_needed!
    self.get("/v3/reports/events/#{event_id}/sales/")
  end

  private

  def get(endpoint)
    response = @access_token.get(endpoint)
    JSON.parse(response.body)
  rescue OAuth2::Error => e
    handle_oauth_error(e)
  end

  def refresh_token_if_needed!
    return unless @access_token.expired?

    new_token = @access_token.refresh!

    # Update the user's tokens
    @user.update(
      eventbrite_token: new_token.token,
      eventbrite_refresh_token: new_token.refresh_token,
      eventbrite_token_expires_at: Time.at(new_token.expires_at)
    )

    # Update the access token instance
    @access_token = new_token
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
