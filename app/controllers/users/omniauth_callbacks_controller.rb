module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def events360
      # auth = request.env['omniauth.auth']
      # puts auth
      puts 'I am in devise controller'
      Rails.logger.debug("Complete Request: #{request.inspect}")

      # Access specific parts of the request
      Rails.logger.debug("Request Method: #{request.method}")
      Rails.logger.debug("Request Path: #{request.fullpath}")
      Rails.logger.debug("Request Parameters: #{params.inspect}")
      # Exchange authorization code for an access token
      exchange_code_for_token(params[:code])
    end

    private

    def exchange_code_for_token(code)
      events_360_app_url = ENV['NXT_APP_URL'].to_s
      events_360_client_id = ENV['NXT_APP_ID'].to_s
      events_360_client_secret = ENV['NXT_APP_SECRET'].to_s
      event_nxt_url = ENV['EVENT_NXT_APP_URL'].to_s
      puts '======================================='
      puts "EVENTS 360 WEBSITE LINK : #{events_360_app_url}"
      puts "EVENTNXT CLIENT ID (REGISTERED IN EVENTS360) : #{events_360_client_id}"
      puts "EVENTNXT SECRET (REGISTERED IN EVENTS360) : #{events_360_client_secret}"
      puts "EVENTNXT WEBSITE LINK : #{event_nxt_url}"
      puts '======================================='
      redirect_uri = "#{event_nxt_url}/auth/events360/callback"
      client = OAuth2::Client.new(events_360_client_id, events_360_client_secret,
        site: events_360_app_url)
      access = client.auth_code.get_token(code, redirect_uri:)

      @user = User.from_omniauth(access)
      if @user.present?
        puts 'user present'
        session[:user_id] = @user.id
        sign_in_and_redirect @user, event: :authentication
      # redirect_to events_path, notice: 'Logged in successfully'
      else
        flash.alert = 'User not found.'
        flash.now[:alert] = 'Invalid request'
        redirect_to sign_in_path,
          notice: 'Invalid username/email or password'
      end
    end
  end
end
