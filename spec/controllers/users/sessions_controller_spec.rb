require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  let(:user) { create(:user, Constants::Events360::SYM) }

  before do
    sign_in user
  end

  describe '#destroy' do
    it 'signs out the user and redirects to root path with a notice' do
      delete :destroy
      expect(controller.current_user).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Signed out successfully.')
    end
  end
end
