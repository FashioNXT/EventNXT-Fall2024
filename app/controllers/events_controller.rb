# frozen_string_literal: true

# EventsController handles the CRUD operations for Event objects.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = current_user.events
  end

  def show
    @event = current_user.events.find(params[:id])

    @event_box_office_data = []

    if @event.event_box_office.present?
      event_box_office_file = @event.event_box_office.current_path
      event_box_office_xlsx = Roo::Spreadsheet.open(event_box_office_file)
      event_box_office_xlsx.each_row_streaming do |row|
        row_data = []
        row.each { |cell| row_data << cell.value }
        @event_box_office_data << row_data
      end

      @referral_data = Referral.where(event_id: @event.id)

      email_index = 0
      tickets_index = 0
      amount_index = 0
      l = @event_box_office_data.first.length
      (0...l).each do |k|
        case @event_box_office_data.first[k]
        when 'Email'
          email_index = k
        when 'Tickets'
          tickets_index = k
        when 'Amount'
          amount_index = k
        end
      end

      @event_box_office_data.drop(1).each do |datum|
        @referral_data.each do |referraldatum|
          referraldatum.update(status: true, tickets: datum[tickets_index], amount: datum[amount_index]) if referraldatum.referred == datum[email_index]
        end
      end

    else
      flash[:notice] = 'No box office spreadsheet uploaded for this event'
    end

    @guests = @event.guests
    @seats = Seat.where(event_id: @event.id)
    @seating_summary = calculate_seating_summary(@event.id, @event_box_office_data.any? ? @event_box_office_data : [])

    @guest_details = Guest.where(event_id: @event.id)
    @referral_data = Referral.where(event_id: @event.id).sort_by do |referraldatum|
      [referraldatum[:referred], referraldatum[:email]]
    end
    @email_templates = EmailTemplate.all
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

  def bulk_action
    # Get the selected guest IDs from the form
    guest_ids = params[:guest_ids]
    email_template_id = params[:email_template_id]

    if guest_ids.nil? || guest_ids.empty?
      flash[:alert] = "No guests selected."
      redirect_to event_path(@event) and return
    end

    case params[:action]
    when 'send_email'
      send_bulk_email(guest_ids, email_template_id)
    when 'delete_guests'
      delete_bulk_guests(guest_ids)
    else
      flash[:alert] = "Invalid action."
      redirect_to event_path(@event) and return
    end

    redirect_to event_path(@event)
  end

  def send_bulk_email(guest_ids, email_template_id)
    guests = Guest.where(id: guest_ids)
    email_template = EmailTemplate.find(email_template_id)
    event = Event.find(email_template.event_id) # Assuming event is associated with the template
  
    guests.each do |guest|
      # Generate referral URL for each guest (this is from the original send_email method)
      full_url = "https://eventnxt-fall2024-demo3-c90f7940fb8e.herokuapp.com/#{book_seats_path(guest.rsvp_link)}"
      referral_url = Rails.application.routes.url_helpers.new_referral_url(
        host: ENV['APP_URL'], random_code: guest.rsvp_link
      )
      # Update email body by replacing the placeholder with the generated referral URL
      updated_body = email_template.body.gsub('PLACEHOLDER_LINK', referral_url)
  
      # Send email using the ApplicationMailer with the updated body for each guest
      ApplicationMailer.send_email(
        guest.email, 
        email_template.subject, 
        updated_body, 
        event, 
        guest,
        full_url
      ).deliver_later
    end
  
    # After emails are sent, show a success message
    flash[:success] = "#{guests.count} emails sent successfully using the #{email_template.name} template."
  end

  def new_email_template
    render '_form_email_template'
  end

  def add_email_template
    email_template_params = params.permit(:name, :subject, :body)
    @email_templates = EmailTemplate.new(email_template_params)

    respond_to do |format|
      if @email_templates.save
        format.html do
          redirect_to email_services_url,
            notice: 'Email template was successfully created.'
        end
      else
        flash[:notice] = 'Error: Email template could not be saved.'
        format.html { render '_form_email_template' }
      end
    end
  end

  def edit_email_template
    @email_template = EmailTemplate.find(params[:id])
    render '_edit_email_template'
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Email template not found' }, status: :not_found
  end

  def update_email_template
    @email_template = EmailTemplate.find(params[:id])
    email_template_params = params.require(:email_template).permit(:name,
      :subject, :body)

    puts "I'm here"

    if @email_template.update(email_template_params)
      redirect_to email_services_url,
        notice: 'Email template was successfully updated.'
    else
      render '_edit_email_template',
        alert: 'Error: Email template could not be saved.'
    end
  end

  def render_template
    email_template = EmailTemplate.find(params[:id])

    respond_to do |format|
      format.json do
        render json: { subject: email_template.subject,
                       body: email_template.body }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Email template not found' }, status: :not_found
  end

  def destroy_email_template
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy

    respond_to do |format|
      format.html do
        redirect_to email_services_url,
          notice: 'Email template was successfully deleted.'
      end
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Email template not found' }, status: :not_found
  end

  def delete_bulk_guests(guest_ids)
    guests = Guest.where(id: guest_ids)
    guests.destroy_all
    flash[:success] = "#{guests.count} guests deleted successfully."
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

  def calculate_seating_summary(event_id, event_box_office_data)
    seating_summary = []
    Seat.where(event_id:).each do |seat|
      guests_in_category = Guest.where(event_id:, category: seat.category)
      guests_in_section = Guest.where(event_id:, section: seat.section)
      total_guests = guests_in_category.and(guests_in_section).distinct.count
      committed_seats = guests_in_category.and(guests_in_section).sum(:commited_seats)
      allocated_seats = guests_in_category.and(guests_in_section).sum(:alloted_seats)
      total_seats = seat.total_count

      tickets_sold = 0

      unless event_box_office_data.empty?
        header_row = event_box_office_data.first

        category_index = header_row.index('Category')
        section_index = header_row.index('Section')
        tickets_index = header_row.index('Tickets') # Column name for tickets

        if category_index && section_index && tickets_index
          event_box_office_data.drop(1).each do |row|
            if row[category_index] == seat.category && row[section_index] == seat.section
              tickets_sold += row[tickets_index].to_i # Convert ticket value to integer
            end
          end
        else
          Rails.logger.error 'Error: Unable to find necessary columns in event box office data.'
        end
      end

      seating_summary << {
        category: seat.category,
        section: seat.section,
        guests_count: total_guests,
        committed_seats:,
        allocated_seats:,
        total_seats:,
        tickets_sold:
      }
    end

    seating_summary
  end

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :address, :description, :datetime, :last_modified, :event_avatar,
      :event_box_office)
  end
end
