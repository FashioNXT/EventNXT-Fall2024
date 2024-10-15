# spec/controllers/tickets_controller_spec.rb
require 'rails_helper'

RSpec.describe TicketsController, type: :controller do
  describe 'GET #new' do
    it 'responds successfully with an HTTP 200 status code' do
      get :new
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    it 'responds with HTTP status ok for AJAX requests' do
      post :create, xhr: true
      expect(response).to have_http_status(:ok)
    end
  end
end
