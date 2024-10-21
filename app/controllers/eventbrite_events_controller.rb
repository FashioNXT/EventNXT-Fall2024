# Eventbrite Events Controller
class EventbriteEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_eventbrite_connected

  def index
    # Fetch events from Eventbrite API
    eventbrite = EventbriteApi.new(current_user)
    response = eventbrite.user_owned_events

    if response['events']
      @ext_events = response['events']
    else
      @ext_events = []
      flash.now[:alert] = 'Could not fetch events from Eventbrite.'
    end
  end

  def show
    event_id = params[:id]
    eventbrite = EventbriteApi.new(current_user)

    # Fetch event details
    @ext_event = eventbrite.get_event(event_id)

    # Fetch ticket classes (types)
    ticket_classes_response = eventbrite.get_ticket_classes(event_id)
    @ext_ticket_classes = ticket_classes_response['ticket_classes'] || []

    # Fetch attendees (to calculate sales)
    attendees_response = eventbrite.get_attendees(event_id)
    @ext_attendees = attendees_response['attendees'] || []

    # Calculate ticket sales
    @ext_ticket_sales = calculate_ticket_sales(@ext_ticket_classes, @ext_attendees)
  end

  private

  def ensure_eventbrite_connected
    return if current_user.eventbrite_token.present?

    redirect_to user_eventbrite_omniauth_authorize_path, alert: 'Please connect your Eventbrite account.'
  end

  def calculate_ticket_sales(ticket_classes, attendees)
    sales = {}

    # Initialize sales data
    ticket_classes.each do |ticket_class|
      sales[ticket_class['id']] = {
        'name' => ticket_class['name'],
        'quantity_sold' => 0,
        'total_sales' => 0.0,
        'currency' => ticket_class['cost'] ? ticket_class['cost']['currency'] : 'USD'
      }
    end

    # Accumulate sales data
    attendees.each do |attendee|
      ticket_class_id = attendee['ticket_class_id']
      quantity = attendee['quantity'].to_i
      gross = attendee['costs']['gross']['value'].to_f / 100 # Convert cents to dollars

      if sales[ticket_class_id]
        sales[ticket_class_id]['quantity_sold'] += quantity
        sales[ticket_class_id]['total_sales'] += gross
      end
    end

    sales.values
  end
end
