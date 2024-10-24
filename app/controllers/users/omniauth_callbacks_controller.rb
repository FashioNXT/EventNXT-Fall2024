module Users
  # Callbacks for the OAuth provider to send code and tokens.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def events360
      @user = nil
      if Rails.env.development?
        # Mock behavior for development
        @user = self.mock_user
      else
        # Omniauth middleware exchange access code with token underhood
        auth = request.env['omniauth.auth']
        @user = User.from_omniauth(auth, current_user)
      end

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

    private

    def mock_user
      mock_user = session[:user] || 'user1'
      auth = case mock_user
             when 'user1'
               OmniAuth.config.mock_auth[Constants::Events360::Mock::USER1]
             when 'user2'
               OmniAuth.config.mock_auth[Constants::Events360::Mock::USER2]
             when 'user3'
               OmniAuth.config.mock_auth[Constants::Events360::Mock::USER3]
             end
      @user = User.find_or_create_by(uid: auth.uid, provider: auth.provider) do |user|
        user.email = auth.info.email
        user.name = auth.info.name
      end
    end
  end
end
