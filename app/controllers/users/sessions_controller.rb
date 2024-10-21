module Users
  # Manully handle user sessions because devise ::database_authenticatable
  # requires password column, which is not needed with OAuth.
  class SessionsController < ApplicationController
    def destroy
      sign_out(current_user)
      redirect_to root_path, notice: 'Signed out successfully.'
    end
  end
end
