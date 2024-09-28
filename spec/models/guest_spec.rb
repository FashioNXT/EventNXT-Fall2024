require 'rails_helper'

RSpec.describe Guest, type: :model do
  describe "associations" do
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:affiliation) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:event_id) }
    it { should validate_numericality_of(:alloted_seats).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:commited_seats).is_greater_than_or_equal_to(0) }
  #  it { should validate_numericality_of(:guest_commited).is_greater_than_or_equal_to(0) }  
  end
end
