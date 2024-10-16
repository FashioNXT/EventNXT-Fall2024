class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def events360
    Rails.logger.debug("Complete Request: #{request.inspect}")
    Rails.logger.debug("Request Method: #{request.method}")
    Rails.logger.debug("Request Path: #{request.fullpath}")
    Rails.logger.debug("Request Parameters: #{params.inspect}")
    
    # Exchange authorization code for an access token
    access_token = exchange_code_for_token(params[:code])
  end

  private

  def exchange_code_for_token(code)
    events_360_app_url = ENV["NXT_APP_URL"].to_s
    events_360_client_id = ENV['NXT_APP_ID'].to_s
    events_360_client_secret = ENV['NXT_APP_SECRET'].to_s
    event_nxt_url = ENV["EVENT_NXT_APP_URL"].to_s
    
    redirect_uri = event_nxt_url + "/auth/events360/callback"
    client = OAuth2::Client.new(events_360_client_id, events_360_client_secret, site: events_360_app_url)

    begin
      access = client.auth_code.get_token(code, redirect_uri: redirect_uri)
    rescue OAuth2::Error => e
      Rails.logger.error("OAuth2 error: #{e.message}")
      redirect_to new_user_session_path, alert: "Failed to authenticate via Event360."
      return
    end

    @user = User.from_omniauth(access)
    if @user.present?
      session[:user_id] = @user.id
      sign_in_and_redirect @user, event: :authentication
    else
      flash.alert = "Invalid username/email or password"
      redirect_to new_user_session_path
    end
  end
end