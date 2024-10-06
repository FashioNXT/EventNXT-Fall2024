require 'rails_helper'

RSpec.describe Devise::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]  # Set the Devise mapping
    @user = create(:user)  # Create a test user
    sign_in @user  # Simulate the user being signed in
  end

  describe 'DELETE #destroy' do
    it 'resets the session and redirects to the login page' do
      delete :destroy  # Simulate the sign-out action
      expect(session[:user_id]).to be_nil  # Check that the session is cleared
      expect(response).to redirect_to(new_user_session_path)  # Check that the user is redirected to the login page
      expect(flash[:notice]).to eq('Signed out successfully.')  # Verify the flash message
    end
  end
end
