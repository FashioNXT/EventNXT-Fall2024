# frozen_string_literal: true

# EventsController handles the CRUD operations for Event objects.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = current_user.events
  end

  # def show
  #   @guests = @event.guests
  #   @seats = Seat.where(event_id: @event.id)

  #   @external_events, @ticket_sales = fetch_and_show_ticket_sales
  #   @spreadsheet_ticket_sales = fetch_spreadsheet_ticket_sales

  #   # Combine ticket sales from both sources
  #   @combined_ticket_sales = @ticket_sales + @spreadsheet_ticket_sales

  #   @seating_summary = @event.calculate_seating_summary(@combined_ticket_sales)
  #   @referral_data = @event.update_referral_data(@combined_ticket_sales)
  # end

  def show
    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)

    @external_events, @ticket_sales = fetch_and_show_ticket_sales

    @seating_summary = @event.calculate_seating_summary(@ticket_sales)

    @referral_data = @event.update_referral_data(@ticket_sales)
  end

  # No changes needed for fetch_and_show_ticket_sales and fetch_spreadsheet_ticket_sales methods.

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
    params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar, :event_box_office, :ticket_source)
  end

  def fetch_and_show_ticket_sales
    external_events = []
    ticket_sales = []

    if @event.ticket_source == 'spreadsheet'
      # Fetch and show Spreadsheet ticket sales
      ticket_sales = fetch_spreadsheet_ticket_sales
    elsif @event.ticket_source == 'eventbrite'
      # Fetch and show Eventbrite ticket sales
      @event.update(external_event_id: params[:external_event_id]) if params[:external_event_id].present? && params[:external_event_id] != @event.external_event_id

      config = TicketVendor::Config.new(event_id: @event.external_event_id)
      @eventbrite_service = TicketVendor::EventbriteHandlerService.new(current_user, config)

      external_events, ticket_sales = self.fetch_and_show_eventbrite if @eventbrite_service.authorized?
    else
      flash[:alert] = 'Invalid ticket source selected.'
      redirect_to events_path and return
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
    else
      flash[:notice] = 'Succuessfully call Eventbrite API!'
    end

    [external_events, ticket_sales]
  end

  def fetch_spreadsheet_ticket_sales
    spreadsheet_ticket_sales = []

    if @event.event_box_office.present?
      event_box_office_file = @event.event_box_office.current_path
      event_box_office_xlsx = Roo::Spreadsheet.open(event_box_office_file)

      headers = event_box_office_xlsx.row(1)
      email_index = headers.index('Email')
      tickets_index = headers.index('Tickets')
      amount_index = headers.index('Amount')
      category_index = headers.index('Category')
      section_index = headers.index('Section')

      event_box_office_xlsx.each_row_streaming(offset: 1) do |row|
        spreadsheet_ticket_sales << {
          email: row[email_index]&.value,
          tickets: row[tickets_index]&.value.to_i,
          cost: row[amount_index]&.value.to_f,
          category: row[category_index]&.value,
          section: row[section_index]&.value
        }
      end
    end

    spreadsheet_ticket_sales
  end
end
