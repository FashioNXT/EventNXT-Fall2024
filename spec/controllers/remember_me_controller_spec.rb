# spec/controllers/remember_me_controller_spec.rb
require 'rails_helper'

RSpec.describe RememberMeController, type: :controller do
  describe '#clear_remember_me' do
    context 'when a user is signed in' do
      let(:user) { create(:user) } # Assuming you have a User factory

      before do
        sign_in user
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'clears the remember-me token for the current user' do
        expect(user).to receive(:forget_me!)
        post :clear_remember_me
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Remember-me token has been cleared.')
      end

      it 'redirects with an alert message' do
        post :clear_remember_me
        expect(response).to redirect_to("http://test.host/")
      end
    end

    context 'when no user is signed in' do
      it 'redirects with an alert message' do
        post :clear_remember_me
        #expect(response).to redirect_to("")
        expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
      end
    end
  end
end

