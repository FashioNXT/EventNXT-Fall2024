require 'rails_helper'

RSpec.describe GuestsImport, type: :model do
  describe 'validations' do
    it 'is invalid without an event_id' do
      import = GuestsImport.new(api_key: 'some_api_key')
      expect(import.valid?).to be false
      expect(import.errors[:event_id]).to include("can't be blank")
    end

    it 'is invalid without an api_key' do
      import = GuestsImport.new(event_id: 123)
      expect(import.valid?).to be false
      expect(import.errors[:api_key]).to include("can't be blank")
    end
  end

  describe '#valid' do
    it 'returns true if the model is valid' do
      import = GuestsImport.new(event_id: 123, api_key: 'some_api_key')
      expect(import.valid).to be true
    end

    it 'returns false if the model is invalid' do
      import = GuestsImport.new(event_id: nil, api_key: nil)
      expect(import.valid).to be false
    end
  end

  describe '#add_guests' do
    let(:import) { GuestsImport.new(event_id: 123, api_key: 'some_api_key') }
    let(:guest_list) do
      [
        {'first_name' => 'John', 'last_name' => 'Doe', 'email' => 'john@example.com'},
        {'first_name' => 'Jane', 'last_name' => 'Doe', 'email' => 'jane@example.com'}
      ]
    end

    it 'successfully adds guests' do
      allow(Guest).to receive(:new_guest).and_call_original
      import.add_guests(guest_list)
      expect(Guest).to have_received(:new_guest).twice
    end

    it 'handles empty guest list' do
      expect { import.add_guests([]) }.not_to raise_error
    end

    it 'handles nil guest list' do
      expect { import.add_guests(nil) }.not_to raise_error
    end
  end
end
