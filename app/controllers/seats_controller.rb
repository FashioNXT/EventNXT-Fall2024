class SeatsController < ApplicationController
  # <!--===================-->
  # <!--corresponding filter of the defined method for nested scaffold-->
  before_action :get_event
  # <!--===================-->
  
  
  before_action :set_seat, only: %i[ show edit update destroy ]

  # GET /seats or /seats.json
  def index
    # @seats = Seat.all
    
    # <!--===================-->
    # <!--to return all children instances associated with a particular parent instance-->
    
    @event = Event.find(params[:event_id])
    @seats = @event.seats
    # <!--===================-->
  end

  # GET /seats/1 or /seats/1.json
  def show
  end

  # GET /seats/new
  def new
    # @seat = Seat.new
    
    # <!--===================-->
    # <!--to create a child object that’s associated with the specific parent instance -->
    @seat = @event.seats.build
    # <!--===================-->
  end

  # GET /seats/1/edit
  def edit
  end

  # POST /seats or /seats.json
  # def create
  #   # @seat = Seat.new(seat_params)
  #   #puts "=== Creating Seat ==="
  #   #Rails.logger.debug(params.inspect)
  #   # <!--===================-->
  #   # <!--to post a new child instance-->
  #   @seat = @event.seats.build(seat_params)
  #   # <!--===================-->

  #   respond_to do |format|
  #     if @seat.save
  #       # format.html { redirect_to seat_url(@seat), notice: "Seat was successfully created." }
  #       format.html { redirect_to event_url(@event), notice: "Seat was successfully created." }
  #       format.json { render :show, status: :created, location: @seat }
  #     else
  #       #Rails.logger.debug(@seat.errors.inspect)
  #       #puts "Errors: #{@seat.errors.inspect}"
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @seat.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  def create
    @seat = @event.seats.build(seat_params)
  
    respond_to do |format|
      if @seat.save
        format.html { redirect_to event_url(@event), notice: "Seat was successfully created." }
        format.json { render :show, status: :created, location: @seat }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @seat.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /seats/1 or /seats/1.json
  def update
    respond_to do |format|
      if @seat.update(seat_params)
        # format.html { redirect_to seat_url(@seat), notice: "Seat was successfully updated." }
        format.html { redirect_to event_seat_path(@event), notice: "Seat was successfully updated." }
        format.json { render :show, status: :ok, location: @seat }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @seat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seats/1 or /seats/1.json
  def destroy
    @seat.destroy

    respond_to do |format|
      # format.html { redirect_to seats_url, notice: "Seat was successfully destroyed." }
      format.html { redirect_to event_seats_path(@event), notice: "Seat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    
    # <!--===================-->
    # <!--to create a local @child instance variable-->
    def get_event
      @event = Event.find(params[:event_id])
    end
    # <!--===================-->
    
    
    
    # Use callbacks to share common setup or constraints between actions.
    def set_seat
      # @seat = Seat.find(params[:id])
      
      # <!--===================-->
      # <!--to search for a matching id in the collection of children associated with a particular parent-->
      @seat = @event.seats.find(params[:id])
      # <!--===================-->
    end

    # Only allow a list of trusted parameters through.
    def seat_params
      params.require(:seat).permit(:category, :section, :total_count, :event_id)
    end
end
