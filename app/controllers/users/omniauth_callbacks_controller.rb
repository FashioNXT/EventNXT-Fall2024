module Users
  # Callbacks for the OAuth provider to send code and tokens.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def events360
      # Omniauth middleware exchange access code with token underhood
      auth = request.env['omniauth.auth']

      @user = User.from_omniauth(auth, current_user)

      if @user.present? && @user.persisted?
        Rails.logger.warn("User #{@user} login through CRM")
        sign_in_and_redirect @user, event: :authentication
      else
        Rails.logger.warn('Login through CRM failed')
        flash.alert = 'Invalid username/email or password'
        redirect_to root_path # new_user_session_path
      end
    end

    def eventbrite
      # Omniauth middleware exchange access code with token underhood
      auth = request.env['omniauth.auth']

      @user = User.from_omniauth(auth, current_user)

      if @user.persisted?
        flash[:notice] = 'Eventbrite account linked successfully.'
      else
        flash[:alert] = 'There was a problem linking your Eventbrite account'
      end
      redirect_to events_path
    end

    # def failure
    #   flash[:alert] = 'Authentication failed. Please try again.'
    #   redirect_to root_path
    # end
  end
end
