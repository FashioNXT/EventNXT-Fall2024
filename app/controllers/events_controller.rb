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


      @referral_data = Referral.where(event_id: @event.id)


      email_index = 0
      tickets_index = 0
      amount_index = 0
      l = @event_box_office_data.first.length 
      for k in 0...l 
        if @event_box_office_data.first[k] == 'Email'
             email_index = k
        elsif @event_box_office_data.first[k] == 'Tickets'
             tickets_index = k         
        elsif @event_box_office_data.first[k] == 'Amount'
             amount_index = k
        end
      end
     
      @event_box_office_data.drop(1).each do |datum|
          @referral_data.each do |referraldatum|
             if referraldatum.referred == datum[email_index]
                referraldatum.update(status: true, tickets: datum[tickets_index], amount: datum[amount_index])                
             end
          end
      end
    else
      flash[:notice] = "No box office spreadsheet uploaded for this event"
      @event_box_office_data = []
    end

    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)
    @seating_summary = calculate_seating_summary(@event.id)
    @guest_details = Guest.where(event_id: @event.id)
    @referral_data = Referral.where(event_id: @event.id).sort_by { |referraldatum| [referraldatum[:referred], referraldatum[:email]] }  
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

  private
    def calculate_seating_summary(event_id)
      seating_summary = []
      
      #seats = Seat.where(event_id: event_id).order(:category, :section)
      Seat.where(event_id: event_id).each do |seat|
      #seats.each do |seat|
        guests_in_category = Guest.where(event_id: event_id, category: seat.category)
        guests_in_section = Guest.where(event_id: event_id, section: seat.section)
        total_guests = guests_in_category.and(guests_in_section).distinct.count
        committed_seats = guests_in_category.and(guests_in_section).sum(:commited_seats)
        allocated_seats = guests_in_category.and(guests_in_section).sum(:alloted_seats)
        total_seats = seat.total_count
    
        seating_summary << {
          category: seat.category,
          section: seat.section,
          guests_count: total_guests,
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


require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event, user: user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @events" do
      get :index
      expect(assigns(:events)).to eq([event])
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: event.id }
      expect(response).to be_successful
    end

    it "assigns @event" do
      get :show, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end

    it "assigns @guests" do
      guest = create(:guest, event: event)
      get :show, params: { id: event.id }
      expect(assigns(:guests)).to include(guest)
    end

    it "assigns @seats" do
      seat = create(:seat, event: event)
      get :show, params: { id: event.id }
      expect(assigns(:seats)).to include(seat)
    end

    it "assigns @seating_summary" do
      get :show, params: { id: event.id }
      expect(assigns(:seating_summary)).to be_an(Array)
    end

    it "assigns @guest_details" do
      guest = create(:guest, event: event)
      get :show, params: { id: event.id }
      expect(assigns(:guest_details)).to include(guest)
    end

  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new event to @event" do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { id: event.id }
      expect(response).to be_successful
    end

    it "assigns the requested event to @event" do
      get :edit, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Event" do
        expect {
          post :create, params: { event: attributes_for(:event) }
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: { event: attributes_for(:event) }
        expect(response).to redirect_to(Event.last)
      end
    end

    # context "with invalid parameters" do
    #   # it "does not create a new Event" do
    #   #   expect {
    #   #     post :create, params: { event: attributes_for(:event, title: nil) }
    #   #   }.to_not change(Event, :count)
    #   # end

    #   # it "renders the 'new' template" do
    #   #   post :create, params: { event: attributes_for(:event, title: nil) }
    #   #   expect(response).to render_template("new")
    #   # end
    # end
  end

  describe "PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Event Title" } }

      it "updates the requested event" do
        put :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.title).to eq("Updated Event Title")
      end

      it "redirects to the event" do
        put :update, params: { id: event.id, event: new_attributes }
        expect(response).to redirect_to(event)
      end
    end

    context "with invalid parameters" do
      it "does not update the event" do
        put :update, params: { id: event.id, event: attributes_for(:event, title: nil) }
        event.reload
        expect(event.title).not_to be_nil
      end

      # it "renders the 'edit' template" do
      #   put :update, params: { id: event.id, event: attributes_for(:event, title: nil) }
      #   expect(response).to render_template("edit")
      # end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      event_to_delete = create(:event, user: user)
      expect {
        delete :destroy, params: { id: event_to_delete.id }
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      delete :destroy, params: { id: event.id }
      expect(response).to redirect_to(events_url)
    end
  end
end
