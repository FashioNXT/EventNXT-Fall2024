class GuestsController < ApplicationController
  # <!--===================-->
  # <!--corresponding filter of the defined method for nested scaffold-->
  before_action :require_event,
    except: %i[book_seats update_commited_seats]
  # <!--===================-->

  before_action :set_guest, only: %i[show edit update destroy]

  # GET /guests or /guests.json
  def index
    @guests = @event.guests
  end

  # GET /guests/1 or /guests/1.json
  def show
    @guests = Guest.all # or another appropriate query to get the guests
  end

  # GET /guests/new
  def new
    # @guest = Guest.new

    # <!--===================-->
    # <!--to create a child object that’s associated with the specific parent instance -->
    @guest = @event.guests.build
    # <!--===================-->
  end

  # GET /guests/1/edit
  def edit
  end

  # POST /guests or /guests.json
  def create
    # @guest = Guest.new(guest_params)

    # <!--===================-->
    # <!--to post a new child instance-->
    @guest = @event.guests.build(guest_params)
    # <!--===================-->

    respond_to do |format|
      if @guest.save
        # format.html { redirect_to guest_url(@guest), notice: "Guest was successfully created." }
        format.html do
          redirect_to event_url(@event),
            notice: 'Guest was successfully created.'
        end
        format.json { render :show, status: :created, location: @guest }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @guest.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /guests/1 or /guests/1.json
  def update
    respond_to do |format|
      if @guest.update(guest_params)
        format.html do
          redirect_to event_path(@event),
            notice: 'Guest was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @guest }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @guest.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /guests/1 or /guests/1.json
  def destroy
    @guest.destroy

    respond_to do |format|
      # format.html { redirect_to guests_url, notice: "Guest was successfully destroyed." }
      format.html do
        redirect_to event_guests_path(@event),
          notice: 'Guest was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  before_action :authenticate_user!
  skip_before_action :authenticate_user!,
    only: %i[book_seats update_commited_seats]

  def book_seats
    @guest = Guest.find_by(rsvp_link: params[:rsvp_link])

    if @guest
      render 'book_seats'
    else
      render plain: 'Invalid RSVP link', status: :not_found
    end
  end

  def update_commited_seats
    @guest = Guest.find_by(rsvp_link: params[:rsvp_link])

    if @guest
      new_commited_seats = params[:guest][:commited_seats].to_i
      total_seats = @guest.commited_seats + new_commited_seats

      if total_seats <= @guest.alloted_seats
        @guest.commited_seats = total_seats

        if @guest.save
          flash[:notice] = 'Committed seats updated successfully.'
          redirect_to book_seats_path(@guest.rsvp_link)
        else
          render 'book_seats'
        end
      else
        flash[:alert] = 'Error: Total seats exceed allocated seats.'
        render 'book_seats'
      end
    else
      render plain: 'Invalid RSVP link', status: :not_found
    end
  end

  def import_spreadsheet
    if params[:file].blank?
      return redirect_to event_path(@event), alert: 'No file uploaded.'
    end

    spreadsheet_file = params[:file]
    result = Guest.import_spreadsheet(spreadsheet_file, @event.id)

    if result[:status] == false
      return redirect_to event_path(@event),
        alert: "Invalid file format: #{result[:message]}"
    end

    redirect_to event_path(@event), notice: 'Guests imported'
  end

  private

  # <!--===================-->
  # <!--to create a local @child instance variable-->
  def require_event
    params.require(:event_id)
    @event = Event.find(params[:event_id])
  end

  # <!--===================-->

  # Use callbacks to share common setup or constraints between actions.
  def set_guest
    # @guest = Guest.find(params[:id])

    # <!--===================-->
    # <!--to search for a matching id in the collection of children associated with a particular parent-->
    @guest = Guest.find(params[:id])
    # <!--===================-->
  end

  # Only allow a list of trusted parameters through.
  def guest_params
    params.require(:guest).permit(
      :first_name, :last_name, :email, :affiliation, :category, :section, :alloted_seats,
      :commited_seats, :status, :event_id
    )
  end
end
