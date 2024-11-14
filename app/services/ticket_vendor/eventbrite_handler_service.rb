require 'monetize'

module TicketVendor
  # Handle data from Eventbrite
  class EventbriteHandlerService
    attr_reader :config, :events, :ticket_sales, :error_message

    def initialize(user, config)
      @user = user
      @config = Config.new(
        event_id: config.event_id,
        category_source_key: config.category_source_key || 'ticket_class_name',
        section_source_key: config.section_source_key || 'ticket_class_name',
        tickets_source_key: config.tickets_source_key || 'quantity',
        cost_source_key: config.cost_source_key || 'costs.base_price.display'
      )
      @eventbrite = EventbriteApiService.new(user) if user.eventbrite_token.present?

      @event_id = config.event_id
      @events = []
      @attendees = []
      @attendees_fields = []
      @ticket_sales = []
      @error_message = nil
    end

    def authorized?
      @user.eventbrite_token.present?
    end

    def disconnect
      @user.update(eventbrite_token: nil)
    end

    def compose_ticket_sales
      email_source_key = 'profile.email'
      @attendees = self.fetch_attendees

      @attendees.each do |attendee|
        ticket_sale = {}
        ticket_sale[Constants::TicketSales::Field::EMAIL] =
          self.get_nested_value(attendee, email_source_key)
        ticket_sale[Constants::TicketSales::Field::CATEGORY] =
          self.get_nested_value(attendee, @config.category_source_key)
        ticket_sale[Constants::TicketSales::Field::SECTION] =
          self.get_nested_value(attendee, @config.section_source_key)
        ticket_sale[Constants::TicketSales::Field::TICKETS] =
          self.get_nested_value(attendee, @config.tickets_source_key)

        cost = self.get_nested_value(attendee, @config.cost_source_key)
        cost = Monetize.parse(cost).amount.to_f / 100.0
        ticket_sale[Constants::TicketSales::Field::COST] = cost

        @ticket_sales << ticket_sale
      end
      @ticket_sales
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

    private

    def get_nested_value(hash, nested_key)
      keys = nested_key.split('.')
      keys.reduce(hash) do |value, key|
        value.is_a?(Hash) ? value[key] : nil
      end
    end
  end
end
