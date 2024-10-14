class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy]

  # GET /events or /events.json
  def index
    @events = current_user.events
  end

  # GET /events/1 or /events/1.json
  def show
    @event = current_user.events.find(params[:id])
    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)
    @seating_summary = calculate_seating_summary(@event.id)
    @guest_details = Guest.where(event_id: @event.id)
    @ticket_sales = @event.ticket_sales
    @referral_data = Referral.where(event_id: @event.id).sort_by do |referraldatum|
      [referraldatum[:referred], referraldatum[:email]]
    end
    # <!--===================-->
  end

  # GET /events/new
  def new
    @event = current_user.events.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
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

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params) && import_result[:status]
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

  # DELETE /events/1 or /events/1.json
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

  def calculate_seating_summary(event_id)
    seating_summary = []

    # seats = Seat.where(event_id: event_id).order(:category, :section)
    Seat.where(event_id:).each do |seat|
      # seats.each do |seat|
      guests_in_category = Guest.where(event_id:,
        category: seat.category)
      guests_in_section = Guest.where(event_id:,
        section: seat.section)
      total_guests = guests_in_category.and(guests_in_section).distinct.count
      committed_seats = guests_in_category.and(guests_in_section).sum(:commited_seats)
      allocated_seats = guests_in_category.and(guests_in_section).sum(:alloted_seats)
      total_seats = seat.total_count

      seating_summary << {
        category: seat.category,
        section: seat.section,
        guests_count: total_guests,
        committed_seats:,
        allocated_seats:,
        total_seats:
      }
    end

    seating_summary
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_user.events.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    # params.require(:event).permit(:title, :address, :description, :datetime, :last_modified)

    # <!--===================-->
    # <!--to add upload field-->
    # params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar)
    params.require(:event).permit(:title, :address, :description, :datetime,
      :last_modified, :event_avatar)
    # <!--===================-->
  end
end
