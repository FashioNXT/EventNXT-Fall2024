module TicketVendor
  # Handle data from Eventbrite
  class EventbriteHandlerService
    attr_reader :events, :ticket_sales, :error_message

    def initialize(user, config)
      @user = user
      @config = Config.new(
        event_id: config.event_id,
        category_source_key: 'ticket_class_name',
        section_source_key: 'ticket_class_name',
        tickets_source_key: 'quantity',
        cost_source_key: 'costs.base_price'
      )
      @eventbrite = EventbriteApiService.new(user) if user.eventbrite_token

      @event_id = config.event_id
      @events = []
      @attendees = []
      @attendees_fields = []
      @ticket_sales = []
      @error_message = nil
    end

    def authorized?
      user.eventbrite_token
    end

    def compose_ticket_sales
      email_source_key = 'profile.email'
      @attendees = self.fetch_attendees
      @ticket_sales = []

      @attendees.each do |attendee|
        ticket_sale = {}
        ticket_sale[:email] = self.get_nested_value(attendee, email_source_key)
        ticket_sale[:category] = self.get_nested_value(attendee, @config.category_source_key)
        ticket_sale[:section] = self.get_nested_value(attendee, @config.section_source_key)
        ticket_sale[:tickets] = self.get_nested_value(attendee, @config.tickets_source_key)
        ticket_sale[:cost] = self.get_nested_value(attendee, @config.cost_source_key)
        ticket_sales << ticket_sale
      end
      ticket_sales
    end

    def fetch_events
      response = @eventbrite.events
      if response.status
        @events = response.data.map do |event|
          { id: event['id'], name: event['name']['text'], url: event['url'] }
        end
      else
        @error_message ||= response.error_message
      end
      @events
    end

    def fetch_attendees
      response = @eventbrite.attendees(@event_id)
      if response.status
        @attendees = response.data
      else
        @error_message ||= response.error_message
      end
      @attendees
    end

    def fetch_attendees_fields
      @attendees = self.fetch_attendees if @attendees.nil

      return [] if @attendees.empty

      self.get_nested_keys(attendees.first)
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
