# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailTemplate, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      email_template = build(:email_template) # Assuming you're using FactoryBot for test data creation
      expect(email_template).to be_valid
    end

    it 'is not valid without a name' do
      email_template = build(:email_template, name: nil)
      expect(email_template).not_to be_valid
      expect(email_template.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a body' do
      email_template = build(:email_template, body: nil)
      expect(email_template).not_to be_valid
      expect(email_template.errors[:body]).to include("can't be blank")
    end
  end
end
