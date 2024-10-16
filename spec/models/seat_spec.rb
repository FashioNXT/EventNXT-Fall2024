# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Seat, type: :model do
  describe 'associations' do
    it { should belong_to(:event) }
  end

  describe 'validations' do
    it { should validate_presence_of(:category) }
    it {
      should validate_numericality_of(:total_count).is_greater_than_or_equal_to(0)
    }
  end
end
