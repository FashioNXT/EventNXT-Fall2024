require 'rails_helper'

RSpec.describe Users::AuthorizeloginController, type: :controller do
  describe '#authorize_event360' do
    it 'redirects to the Event360 authorization endpoint with the correct parameters' do
      allow(ENV).to receive(:[]).with('NXT_APP_URL').and_return('http://example.com')
      allow(ENV).to receive(:[]).with('NXT_APP_ID').and_return('your_client_id')
      allow(ENV).to receive(:[]).with('EVENT_NXT_APP_URL').and_return('http://example-callback.com')

      expect do
        get :authorize_event360
      end.to redirect_to('http://example.com/oauth/authorize?client_id=your_client_id&redirect_uri=http://example-callback.com/auth/events360/callback&response_type=code&scope=public')
    end

    # Add more tests as needed
  end
end
