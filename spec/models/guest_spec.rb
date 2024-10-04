require 'rails_helper'
require 'roo'

RSpec.describe Guest, type: :model do
  # Parent Models
  let(:user) {User.create!(email: "test@example", password: "password", password_confirmation: "password")}
  let(:event) {Event.create!(title: "Test Event", user_id: user.id)}

  describe "associations" do
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:affiliation) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:section) }
    it { should validate_presence_of(:event_id) }
    it { should validate_numericality_of(:alloted_seats).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:commited_seats).is_greater_than_or_equal_to(0) }
  end

  describe ".import_spreadsheet" do
    
    let(:spreadsheet) {Roo::Spreadsheet.open("spec/fixtures/files/guests.xlsx")}
    
    it 'imports new guests from a spreadsheet' do
      allow(Guest).to receive(:validate_import).and_return({status: true, message: "Spreadsheet validated successfully"})
      
      expect(Guest.count).to eq(0)
      result = Guest.import_spreadsheet(spreadsheet, event.id)

      expect(result[:status]).to be(true)
      expect(Guest.count).to eq(3)

      guest = Guest.first
      expect(guest.last_name).to eq('Pampati')
      expect(guest.email).to eq('Anirith@sample.com')
      
      guest = Guest.last
      expect(guest.last_name).to eq('Adluri')
      expect(guest.email).to eq('Pavan@sample.com')
    end
  end
end
