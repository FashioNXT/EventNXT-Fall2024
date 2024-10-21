module Users
  # Callbacks for the OAuth provider to send code and tokens.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def events360
      # Omniauth middleware exchange access code with token underhood
      auth = request.env['omniauth.auth']
      @user = User.from_omniauth(auth, current_user)

      if @user.present? && @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.event360_data'] = auth.except('extra')
        redirect_to root_path, alert: @user.errors.full_messages.join("\n")
      end
    end

    def failure
      flash[:alert] = 'Authentication failed. Please try again.'
      redirect_to root_path
    end
  end
end
