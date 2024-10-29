module TicketVendor
  # Handle data from Eventbrite
  class EventbriteHandlerService
    attr_reader :events, :ticket_sales, :error_message

    def initialize(user, config)
      @user = user
      @config = config
      @eventbrite = EventbriteApiService.new(user) if user.eventbrite_token

      @event_id = config.event_id

      @events = self.fetch_events
      @ticket_class_fields = self.fetch_ticket_class_fields
      @ticket_sales = self.compose_ticket_sales
      @error_message = nil
    end

    def authorized?
      user.eventbrite_token
    end

    def compose_ticket_sales
      email_source_key = 'profiles.'
    end

    def fetch_events
      response = @eventbrite.events
      if response.status
        @external_events = response.data
      else
        @error_message = response.error_message
      end
    end

    def fetch_ticket_classes_by_id
      response = @eventbrite.tickets_classes(@event_id)
      ticket_classes_by_id = {}
      if response.status
        ticket_classes_by_id = response.data.each_with_object({}) do |ticket_class, classes_by_id|
          classes_by_id[ticket_class['id']] = ticket_class
        end
      else
        @error_message ||= ticket_response.error_message
      end
      ticket_classes_by_id
    end

    def fetch_ticket_class_fields
      ticket_classes_by_id = self.fetch_ticket_classes_by_id
      return [] if ticket_classes.nil? || ticket_classes.empty?

      self.get_nested_keys(ticket_classes_by_id.values.first)
    end

    def fetch_attendees
      response = @eventbrite.attendees(@event_id)
      attendees = []
      if response.status
        attendees = response.data
      else
        @error_message ||= ticket_response.error_message
      end
      attendees
    end

    private

    def get_nested_keys(hash, parent_key = '')
      keys = []
      hash.each do |key, value|
        full_key = parent_key.empty? ? key.to_s : "#{parent_key}.#{key}"
        if value.is_a?(Hash)
          keys.concat(fetch_nested_keys(value, full_key))
        else
          keys << full_key
        end
      end
    end

    def get_nested_value(hash, nested_key)
      keys = nested_key.split('.')
      keys.reduce(hash) do |value, key|
        value.is_a?(Hash) ? value[key] : nil
      end
    end
  end
end
