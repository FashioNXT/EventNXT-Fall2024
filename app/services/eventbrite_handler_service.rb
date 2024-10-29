# Handle data from Eventbrite
class EventbriteHandlerService
  attr_reader :events, :ticket_sales, :error_message

  def initialize(user, event_id = nil)
    @user = user
    @eventbrite = EventbriteApiService.new(user) if user.eventbrite_token
    @event_id = event_id
    @ticket_sales = []
    @error_message = nil

    self.fetch_events_and_tickets if self.authorized?
  end

  def authorized?
    user.eventbrite_token
  end

  private

  def fetch_events_and_tickets
    fetch_events
    fetch_ticket_sales if @event_id
  end

  def fetch_events
    response = @eventbrite.events
    if response.status
      @external_events = response.data
    else
      @error_message = response.error_message
    end
  end

  def fetch_tickets
    response = @eventbrite.tickets(@eventbrite_event_id)
    if response.status
      @ticket_sales = response.data
    else
      @error_message ||= ticket_response.error_message
    end
  end
end
