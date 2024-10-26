# frozen_string_literal: true

require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) } # Create a user for authentication
  let(:event) { create(:event, user:) }

  describe 'associations' do
    it { should have_many(:seats).dependent(:destroy) }
    it { should have_many(:guests).dependent(:destroy) }
  end
end
