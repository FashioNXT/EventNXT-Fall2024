class EventsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_event, only: %i[ show edit update destroy ]

  # GET /events or /events.json
  def index
    @events = current_user.events
  end

  # GET /events/1 or /events/1.json
  def show
    # <!--===================-->
    # <!--to show the uploaded spreadsheet-->
    @event = current_user.events.find(params[:id])
    if @event.event_box_office.present?
      @event_box_office_data = []
      # Load the spreadsheet using the SpreadsheetUploader
      event_box_office_file = @event.event_box_office.current_path
      # Parse the contents of the event_box_office_file using Roo
      event_box_office_xlsx = Roo::Spreadsheet.open(event_box_office_file)
      event_box_office_xlsx.each_row_streaming do |row|
      # event_box_office_xlsx.each_row_streaming(max_rows: 2) do |row|
        row_data = []
        row.each { |cell| row_data << cell.value }
        @event_box_office_data << row_data
    end
    else
      flash[:notice] = "No box office spreadsheet uploaded for this event"
      @event_box_office_data = []
    end

    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)
    @seating_summary = calculate_seating_summary(@event.id)
    @guest_details = Guest.where(event_id: @event.id)
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
        format.html { redirect_to event_url(@event), notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to event_url(@event), notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end
 
  def import_previous_guest_information
    previous_guest_csv_file = params[:documentation]
    if previous_guest_csv_file.present? && previous_guest_csv_file.respond_to?(:read)
          previous_guest_csv_file_data = CSV.read(previous_guest_csv_file, headers: true) 
          row_number = previous_guest_csv_file_data.length
          for k in 0...row_number do
            related_event_parametrization = {
              id: previous_guest_csv_file_data[k]['event id'].to_f,
              title: previous_guest_csv_file_data[k]['title'],
              address: previous_guest_csv_file_data[k]['address'],
              description: previous_guest_csv_file_data[k]['description'],
              datetime: previous_guest_csv_file_data[k]['datetime'],
              event_avatar: previous_guest_csv_file_data[k]['event avatar'],
              event_box_office: previous_guest_csv_file_data[k]['event box office'],
              user_id: current_user.id
            }
            @event_for_this_functionality = Event.find_or_create_by(related_event_parametrization)
            @event_for_this_functionality.save
            if @event_for_this_functionality.save 
              previous_guest_parameters = {
                id: previous_guest_csv_file_data[k]['guest id'].to_f,
                first_name: previous_guest_csv_file_data[k]['guest first name'],
                last_name: previous_guest_csv_file_data[k]['guest last name'],
                affiliation: previous_guest_csv_file_data[k]['guest affiliation'],
                category: previous_guest_csv_file_data[k]['guest category'],
                alloted_seats: previous_guest_csv_file_data[k]['guest alloted seats'].to_f,
                commited_seats: previous_guest_csv_file_data[k]['guest commited seats'].to_f,
                guest_commited: previous_guest_csv_file_data[k]['guest commited'].to_f,
                status: previous_guest_csv_file_data[k]['guest status'],
                event_id: previous_guest_csv_file_data[k]['guest event id'].to_f, 
                email: previous_guest_csv_file_data[k]['guest email'],
                rsvp_link: previous_guest_csv_file_data[k]['guest rsvp link'] 
              }
              @guest_for_this_functionality = Guest.find_or_create_by(previous_guest_parameters)
              @guest_for_this_functionality.save           
            end
          end 
          flash[:notice] = 'Completed importing previous guest information!'         
    else
      flash[:notice]= 'No file uploaded or your file is not valid.'
    end
  end







  private
    def calculate_seating_summary(event_id)
      seating_summary = []
    
      Seat.where(event_id: event_id).each do |seat|
        guests_in_category = Guest.where(event_id: event_id, category: seat.category)
        committed_seats = guests_in_category.sum(:commited_seats)
        allocated_seats = guests_in_category.sum(:alloted_seats)
        total_seats = seat.total_count
    
        seating_summary << {
          category: seat.category,
          guests_count: guests_in_category.count,
          committed_seats: committed_seats,
          allocated_seats: allocated_seats,
          total_seats: total_seats
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
      params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar, :event_box_office)
      # <!--===================-->
      
    end
end
