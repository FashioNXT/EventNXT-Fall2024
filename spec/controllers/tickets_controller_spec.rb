require 'rails_helper'

RSpec.describe TicketsController, type: :controller do
  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with AJAX request' do
      it 'returns a status code 200' do
        post :create, xhr: true
        expect(response).to have_http_status(:ok)
      end
    end
  end
end