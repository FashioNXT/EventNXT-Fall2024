# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailService, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      email_service = EmailService.new
      expect(email_service).to be_valid
    end
  end
end
