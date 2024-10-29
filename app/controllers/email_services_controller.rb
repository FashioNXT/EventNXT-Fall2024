class EmailServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_service, only: %i[show edit update destroy send_email]

  # Send email with referral and booking links
  def send_email
    event = @email_service.event
    guest = Guest.find(@email_service.guest_id)

    # Build referral and booking URLs
    referral_url = Rails.application.routes.url_helpers.new_referral_url(
      host: 'https://eventnxt-0fcb166cb5ae.herokuapp.com', random_code: guest.rsvp_link
    )
    full_url = "https://eventnxt-0fcb166cb5ae.herokuapp.com/#{book_seats_path(guest.rsvp_link)}"

    # Replace placeholder in email body
    updated_body = @email_service.body.gsub('PLACEHOLDER_LINK', referral_url)

    # Send email
    ApplicationMailer.send_email(@email_service.to, @email_service.subject, updated_body, event, guest, full_url).deliver_later
    @email_service.update(sent_at: Time.current)

    flash[:success] = 'Email sent!'
    redirect_to email_services_url
  end

  # GET /email_services or /email_services.json
  def index
    @email_services = EmailService.all
    @sent_emails = EmailService.where.not(sent_at: nil) # Sent emails
    @unsent_emails = EmailService.where(sent_at: nil) # Unsent emails
    @email_templates = EmailTemplate.all
  end

  # GET /email_services/1 or /email_services/1.json
  def show; end

  # GET /email_services/new
  def new
    @email_service = EmailService.new
    @events = Event.all
  end

  # GET /email_services/1/edit
  def edit; end

  # POST /email_services or /email_services.json
  def create
    @email_service = EmailService.new(email_service_params)

    respond_to do |format|
      if @email_service.save
        format.html { redirect_to email_services_url, notice: 'Email service was successfully created.' }
        format.json { render :show, status: :created, location: @email_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_services/1 or /email_services/1.json
  def update
    respond_to do |format|
      if @email_service.update(email_service_params)
        format.html { redirect_to email_services_url, notice: 'Email service was successfully updated.' }
        format.json { render :show, status: :ok, location: @email_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_services/1 or /email_services/1.json
  def destroy
    @email_service.destroy
    respond_to do |format|
      format.html { redirect_to email_services_url, notice: 'Email service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Render form for new email template
  def new_email_template
    render '_form_email_template'
  end

  # Create a new email template
  def add_email_template
    email_template_params = params.permit(:name, :subject, :body)
    @email_template = EmailTemplate.new(email_template_params)

    if @email_template.save
      redirect_to email_services_url, notice: 'Email template was successfully created.'
    else
      flash[:alert] = 'Error: Email template could not be saved.'
      render '_form_email_template'
    end
  end

  # Render form for editing an email template
  def edit_email_template
    @email_template = EmailTemplate.find(params[:id])
    render '_edit_email_template'
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Email template not found'
    redirect_to email_services_url
  end

  # Update an email template
  def update_email_template
    @email_template = EmailTemplate.find(params[:id])
    email_template_params = params.require(:email_template).permit(:name, :subject, :body)

    if @email_template.update(email_template_params)
      redirect_to email_services_url, notice: 'Email template was successfully updated.'
    else
      flash[:alert] = 'Error: Email template could not be updated.'
      render '_edit_email_template'
    end
  end

  # Render email template data in JSON format
  def render_template
    email_template = EmailTemplate.find(params[:id])
    render json: { subject: email_template.subject, body: email_template.body }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Email template not found' }, status: :not_found
  end

  # Delete an email template
  def destroy_email_template
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy
    flash[:notice] = 'Email template was successfully deleted.'
    redirect_to email_services_url
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Email template not found'
    redirect_to email_services_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_email_service
    @email_service = EmailService.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def email_service_params
    params.require(:email_service).permit(:email_template_id, :to, :subject, :body, :sent_at, :committed_at, :event_id, :guest_id)
  end
end
