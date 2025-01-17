# frozen_string_literal: true

require 'csv'

# EventsController handles the CRUD operations for Event objects.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy download_guests]

  TICKET_SALES = Constants::TicketSales

  def index
    @events = current_user.events
  end

  def download_guests
    @guests = @event.guests

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << ['First Name', 'Last Name', 'Email', 'Affiliation', 'Category',
                  'Section', 'Allocated Seats', 'Committed Seats', 'Status']

          @guests.each do |guest|
            csv << [
              guest.first_name,
              guest.last_name,
              guest.email,
              guest.affiliation,
              guest.category,
              guest.section,
              guest.alloted_seats,
              guest.commited_seats,
              guest.status
            ]
          end
        end

        send_data csv_data,
          filename: "guests_list_#{@event.title}_#{Date.today}.csv"
      end
    end
  end

  def show
    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)

    @external_events, @ticket_sales = fetch_and_show_ticket_sales

    @seating_summary = @event.calculate_seating_summary(@ticket_sales)

    @referral_data = @event.update_referral_data(@ticket_sales)
  end

  def new
    @event = current_user.events.new
  end

  def edit; end

  def create
    @event = current_user.events.new(event_params)

    respond_to do |format|
      if @event.save
        format.html do
          redirect_to event_url(@event),
            notice: 'Event was successfully created.'
        end
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @event.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html do
          redirect_to event_url(@event),
            notice: 'Event was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @event.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html do
        redirect_to events_url, notice: 'Event was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar,
      :event_box_office, :ticket_source)
  end

  def fetch_and_show_ticket_sales
    external_events = []
    ticket_sales = []

    if @event.ticket_source == TICKET_SALES::Source::SPREADSHEET
      # Fetch and show Spreadsheet ticket sales
      spreadsheet_service = TicketSalesSpreadsheetService.new(@event)
      ticket_sales = spreadsheet_service.import_data(@event.event_box_office)
    elsif @event.ticket_source == TICKET_SALES::Source::EVENTBRITE
      # Fetch and show Eventbrite ticket sales
      if params[:external_event_id].present? && params[:external_event_id] != @event.external_event_id
        @event.update(external_event_id: params[:external_event_id])
      end

      config = TicketVendor::Config.new(event_id: @event.external_event_id)
      @eventbrite_service = TicketVendor::EventbriteHandlerService.new(current_user, config)

      external_events, ticket_sales = self.fetch_and_show_eventbrite if @eventbrite_service.authorized?
    end

    ticket_sales_validator = TicketSalesValidatorService.new(@event)
    ticket_sales_validator.validate(ticket_sales)

    [external_events, ticket_sales]
  end

  def fetch_and_show_eventbrite
    ticket_sales = []

    external_events = @eventbrite_service.fetch_events
    ticket_sales =  @eventbrite_service.compose_ticket_sales if @eventbrite_service.config.event_id.present?

    if @eventbrite_service.error_message.present?
      flash[:alert] = @eventbrite_service.error_message
      ticket_sales = []
    end

    [external_events, ticket_sales]
  end
end
