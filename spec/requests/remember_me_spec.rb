# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RememberMes', type: :request do
  describe 'GET /clear_remember_me' do
    it 'returns http success' do
      get '/remember_me/clear_remember_me'
      expect(response).to have_http_status(302)
    end
  end
end
