# frozen_string_literal: true

# EmailServicesController
class EmailServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_service, only: %i[show edit update destroy]

  # <!--===================-->
  # <!--to add mailing service-->
  def send_email
    email_service = EmailService.find(params[:id])
    event = Event.find(email_service.event_id)
    guest = Guest.find(email_service.guest_id)

    # full_url = ENV['localhost:3000'].to_s + book_seats_path(guest.rsvp_link)
    # full_url = "http://0.0.0.0:3000/#{book_seats_path(guest.rsvp_link)}"
    full_url = URI.join(Constants::APP_URL, book_seats_path(guest.rsvp_link)).to_s
    # print full_url

    # the referral link takes the form of '/refer_a_friend?:ref_code'.
    # params[:ref_code] = guest.id will be the parameter value to be used.
    # we have the referral link takes the form of '/refer_a_friend?guest.id' to transfer the parameters.
    # random_code_generated = SecureRandom.hex(20)

    referral_url = Rails.application.routes.url_helpers.new_referral_url(
      host: ENV['APP_URL'], random_code: guest.rsvp_link
    )
    # referral_url = Rails.application.routes.url_helpers.new_referral_url(
    # host: 'https://eventnxt-0fcb166cb5ae.herokuapp.com/', random_code: guest.rsvp_link
    # )

    # referral_url = ENV['localhost:3000'].to_s + new_referral_path(guest.id)

    updated_body = email_service.body.gsub('PLACEHOLDER_LINK', referral_url)

    ApplicationMailer.send_email(email_service.to, email_service.subject, updated_body, event, guest,
      full_url).deliver_later

    flash[:success] = 'Email sent!'
    email_service.update(sent_at: Time.current)
    redirect_to email_services_url
  end

  # <!--===================-->

  # GET /email_services or /email_services.json
  def index
    # puts ("------------------------------")
    @email_services = EmailService.all
    # puts("In index controller");

    # <!--===================-->
    # <!--to filter emails based on their sent_at status-->
    @sent_emails = EmailService.where.not(sent_at: nil) # Get all sent emails
    @unsent_emails = EmailService.where(sent_at: nil) # Get all unsent emails
    @email_templates = EmailTemplate.all
    # <!--===================-->
  end

  # GET /email_services/1 or /email_services/1.json
  def show
    # puts("****************")
    # puts("reached here")
    @email_service = EmailService.find(params[:id])
    # puts(@email_service)
    # puts("****************")
    render :show
  end

  # GET /email_services/new
  def new
    @email_service = EmailService.new

    # <!--===================-->
    # <!--to have access to another model-->
    @events = Event.all
    # <!--===================-->
  end

  # GET /email_services/1/edit
  def edit; end

  # POST /email_services or /email_services.json
  def create
    @email_service = EmailService.new(email_service_params)
    puts email_service_params

    respond_to do |format|
      if @email_service.save
        format.html do
          redirect_to email_services_url,
            notice: 'Email service was successfully created.'
        end
        format.json { render :show, status: :created, location: @email_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @email_service.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /email_services/1 or /email_services/1.json
  def update
    respond_to do |format|
      if @email_service.update(email_service_params)
        format.html do
          redirect_to email_service_url,
            notice: 'Email service was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @email_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @email_service.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /email_services/1 or /email_services/1.json
  def destroy
    @email_service.destroy

    respond_to do |format|
      format.html do
        redirect_to email_services_url,
          notice: 'Email service was successfully destroyed.'
      end
      format.json { head :no_content }
    end
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
  
    # Remove HTML tags and format the text properly
    plain_text_body = email_template.body
      .gsub('<%= @event.title %>', '[event_title]')
      .gsub('<%= @guest.first_name %>', '[guest_first_name]')
      .gsub('<%= @guest.last_name %>', '[guest_last_name]')
      .gsub('<%= @event.datetime %>', '[event_datetime]')
      .gsub('<%= @event.description %>', '[event_description]')
      .gsub('<%= @event.address %>', '[event_address]')
      .gsub('<%= @rsvp_url %>', '[rsvp_url]')
      .gsub(/<\/?[^>]*>/, '') # Remove all HTML tags
      .gsub(/<br\s*\/?>/, "\n") # Convert <br> tags to newlines
      .gsub(/&nbsp;/, ' ') # Replace non-breaking spaces
      .strip # Remove leading/trailing whitespace
  
    respond_to do |format|
      format.json do
        render json: { subject: email_template.subject, body: plain_text_body }
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_email_service
    @email_service = EmailService.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def email_service_params
    # params.require(:email_service).permit(:to, :subject, :body)
    # params.require(:email_service).permit(:to, :subject, :body, :sent_at, :committed_at)
    # params.require(:email_service).permit(:to, :subject, :body, :sent_at, :committed_at, :event_id)
    params.require(:email_service).permit(:email_template_id, :to, :subject, :body, :sent_at, :committed_at,
      :event_id, :guest_id)
  end
end
