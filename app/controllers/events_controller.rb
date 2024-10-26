# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = current_user.events
  end

  def show
    @event = current_user.events.find(params[:id])

    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)
    @seating_summary = @event.calculate_seating_summary

    @guest_details = Guest.where(event_id: @event.id)
    @referral_data = Referral.where(event_id: @event.id).sort_by do |referraldatum|
      [referraldatum[:referred], referraldatum[:email]]
    end
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
    params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar)
  end
end
