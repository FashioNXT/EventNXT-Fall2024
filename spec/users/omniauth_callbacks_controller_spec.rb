require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe '#events360' do
    let(:user) { create(:user) }

    it 'exchanges code for token and signs in the user' do
      allow(ENV).to receive(:[]).with('NXT_APP_URL').and_return('http://example.com')
      allow(ENV).to receive(:[]).with('NXT_APP_ID').and_return('your_client_id')
      allow(ENV).to receive(:[]).with('NXT_APP_SECRET').and_return('your_client_secret')
      allow(ENV).to receive(:[]).with('EVENT_NXT_APP_URL').and_return('http://example-callback.com')

      expect(controller).to receive(:exchange_code_for_token).with('your_code').and_return(true)
      allow(controller).to receive(:sign_in_and_redirect)

      get :events360, params: { code: 'your_code' }

      expect(response).to have_http_status(:success)
      expect(controller).to have_received(:exchange_code_for_token).with('your_code')
      expect(controller).to have_received(:sign_in_and_redirect).with(user,
        event: :authentication)
    end

    # Add more tests as needed
  end
end
