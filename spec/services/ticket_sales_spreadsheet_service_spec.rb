require 'rails_helper'

RSpec.describe TicketSalesSpreadsheetService, type: :service do
  let(:event) { create(:event) }
  let(:spreadsheet_path) { Rails.root.join('spec', 'fixtures', 'files', 'new ticketlist.xlsx').to_s }
  let(:spreadsheet_file) { double('Spreadsheet', current_path: spreadsheet_path) }

  before do
    allow(event).to receive(:event_box_office).and_return(spreadsheet_file)
  end


  describe '#import_data' do
    subject { TicketSalesSpreadsheetService.new(event).import_data }

    context 'when spreadsheet is present' do
      before do
        allow(Roo::Spreadsheet).to receive(:open).with(spreadsheet_path).and_call_original
      end

      it 'reads the spreadsheet and returns parsed data' do
        data = subject

        expect(data).to be_an(Array)
        expect(data).not_to be_empty

        first_row = data.first
        expect(first_row.keys).to match_array(%i[email tickets cost category section])
        expect(first_row[:email]).to be_a(String).or be_nil
        expect(first_row[:tickets]).to be_a(Integer)
        expect(first_row[:cost]).to be_a(Float)
        expect(first_row[:category]).to be_a(String).or be_nil
        expect(first_row[:section]).to be_a(String).or be_nil
      end
    end

    context 'when spreadsheet is not present' do
      before do
        allow(event).to receive(:event_box_office).and_return(nil)
      end

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end
  end
end
