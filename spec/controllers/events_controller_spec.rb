# frozen_string_literal: true

require 'rails_helper'
RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) } # Create a user for authentication
  before do
    sign_in user # Sign in the user before running the tests
  end
  describe 'GET #show' do
    it 'returns a success response' do
      # Use the factory to create a sample event
      event = create(:event, user:)
      # Perform your test using the created event
      get :show, params: { id: event.to_param }
      expect(response).to be_successful
    end
  end

  # describe 'GET #show' do
  #   context 'when a box office spreadsheet is uploaded with seat bookings' do
  #     let(:spreadsheet_file) do
  #       fixture_file_upload(Rails.root.join('test', 'fixtures', 'files', 'new_ticketlist.xlsx'))
  #     end

  #     # Mock the spreadsheet data to simulate the rows being read from the spreadsheet
  #     let(:spreadsheet_data) do
  #       [
  #         ['John', 'Holmes', 'john.holmes@sq1.com', 'test', 'R1 PATRON', 4, 'A', 125],
  #         ['joanne', 'burdick', 'jdburdickpdx@gmail.com', 'test', 'R1 PATRON', 4, 'A', 125],
  #         ['Peta', 'Sklarz', 'petasklarz@gmail.com', 'test', 'PREF R5', 3, 'A', 40],
  #         ['ANGELLA', 'THEUNISSEN', 'vegasboooty@yahoo.com', 'test', 'R1 PATRON', 1, 'A', 125],
  #         ['Lynn', 'Laughton', 'dennislaughton1@yahoo.com', 'test', 'PREF R3', 2, 'A', 62],
  #         ['Estefania', 'Nateras', 'salemaccidentcare@gmail.com', 'test', 'PREF R3', 2, 'A', 49.5],
  #         ['ARIANNA', 'GARCIA', 'Ary29_p@hotmail.com', 'test', 'PREF R3', 1, 'A', 49.5],
  #         ['SANDI', 'JARQUIN', 'SANDIJARQUIN_MUA@YAHOO.COM', 'test', 'PREF R3', 1, 'A', 49.5],
  #         ['Alicia', 'Reese', 'alicia@sockittome.com', 'test', 'PREF R5', 4, 'A', 36],
  #         ['Ana', 'Saavedra', 'anysaavedra21@hotmail.com', 'test', 'PREF R3', 1, 'A', 49.5]
  #       ]
  #     end

  #     before do
  #       # Create a mock object for the spreadsheet

  #       mock_spreadsheet = instance_double(Roo::Excelx)
      
  #       # Mock opening the spreadsheet file to return the mock spreadsheet
  #       allow(Roo::Spreadsheet).to receive(:open).and_return(mock_spreadsheet)
      
  #       # Mock returning sheet names from the spreadsheet
  #       allow(mock_spreadsheet).to receive(:sheets).and_return(['Sheet1'])
      
  #       # Mock selecting a specific sheet
  #       allow(mock_spreadsheet).to receive(:sheet).with('Sheet1').and_return(mock_spreadsheet)
      
  #       # Mock the streaming of rows from the sheet
  #       allow(mock_spreadsheet).to receive(:each_row_streaming).and_return(spreadsheet_data.each)
      
  #       # Create seats in the event (total seat count in each category)
  #       create(:seat, event: event, category: 'R1 PATRON', section: 'A', total_count: 100)
  #       create(:seat, event: event, category: 'PREF R3', section: 'A', total_count: 100)
  #       create(:seat, event: event, category: 'PREF R5', section: 'A', total_count: 100)
  #     end
      
  #     it 'calculates the correct number of booked seats for each category from the spreadsheet' do
  #       # Call the show action
  #       get :show, params: { id: event.id }

  #       # Access the seating summary that should be calculated in the controller
  #       seating_summary = assigns(:seating_summary)

  #       # Verify booked seats for R1 PATRON
  #       r1_patron_summary = seating_summary.find { |summary| summary[:category] == 'R1 PATRON' }
  #       expect(r1_patron_summary[:booked_seats]).to eq(9) # 4 + 4 + 1 seats booked

  #       # Verify booked seats for PREF R3
  #       pref_r3_summary = seating_summary.find { |summary| summary[:category] == 'PREF R3' }
  #       expect(pref_r3_summary[:booked_seats]).to eq(7) # 2 + 2 + 1 + 1 + 1 seats booked

  #       # Verify booked seats for PREF R5
  #       pref_r5_summary = seating_summary.find { |summary| summary[:category] == 'PREF R5' }
  #       expect(pref_r5_summary[:booked_seats]).to eq(7) # 3 + 4 seats booked
  #     end
  #   end
  # end
  describe 'GET #show' do
    context 'when a box office spreadsheet is uploaded with seat bookings' do
      # let(:event) { create(:event, user: user) } # Define event here

      let(:spreadsheet_file) do
        fixture_file_upload(Rails.root.join('test', 'fixtures', 'files', 'new_ticketlist.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end
      # puts :spreadsheet_file
      let(:event) do
        create(:event, user: user, event_box_office: spreadsheet_file)
      end
      
      it "calculates the correct number of booked seats for each category from the spreadsheet" do
        get :show, params: { id: event.id }

        seating_summary = assigns(:seating_summary)

        puts seating_summary
        
        r1_patron_summary = seating_summary.find { |summary| summary[:category] == "R1 PATRON" }
        expect(r1_patron_summary[:tickets_sold]).to eq(9) # Corrected key name to match controller logic

        pref_r3_summary = seating_summary.find { |summary| summary[:category] == "PREF R3" }
        expect(pref_r3_summary[:tickets_sold]).to eq(7)

        pref_r5_summary = seating_summary.find { |summary| summary[:category] == "PREF R5" }
        expect(pref_r5_summary[:tickets_sold]).to eq(7)
      end
      # it 'calculates the correct number of booked seats for each category from the spreadsheet' do
      #   get :show, params: { id: event.id }
      
      #   seating_summary = assigns(:seating_summary)
      
      #   r1_patron_summary = seating_summary.find { |summary| summary[:category] == 'R1 PATRON' }
      #   expect(r1_patron_summary[:tickets_sold]).to eq(9) # Ensure this matches controller logic
      
      #   pref_r3_summary = seating_summary.find { |summary| summary[:category] == 'PREF R3' }
      #   expect(pref_r3_summary[:tickets_sold]).to eq(7)
      
      #   pref_r5_summary = seating_summary.find { |summary| summary[:category] == 'PREF R5' }
      #   expect(pref_r5_summary[:tickets_sold]).to eq(7)
      # end
      
    end
  end


  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:event) { create(:event, user:) }

    it 'returns a success response' do
      get :show, params: { id: event.to_param }
      expect(response).to be_successful
    end

    context 'when the event has a box office spreadsheet uploaded' do
      let(:event_with_box_office) { create(:event, :with_box_office, user:) }

      it 'loads the box office spreadsheet' do
        get :show, params: { id: event_with_box_office.to_param }
        expect(assigns(:event_box_office_data)).not_to be_nil
      end
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    let(:event) { create(:event, user:) }

    it 'returns a success response' do
      get :edit, params: { id: event.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { attributes_for(:event) }

      it 'creates a new event' do
        puts(@event)
        expect do
          post :create, params: { event: valid_params }
        end.to change(Event, :count).by(1)
      end

      it 'redirects to the created event' do
        post :create, params: { event: valid_params }
        expect(response).to redirect_to(Event.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:event, title: nil) }

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { event: invalid_params }
        expect(response).to render_template(nil)
      end
    end
  end

  describe 'PUT #update' do
    let(:event) { create(:event, user:) }

    context 'with valid params' do
      let(:new_params) { attributes_for(:event, title: 'New Title') }

      it 'updates the requested event' do
        put :update, params: { id: event.to_param, event: new_params }
        event.reload
        expect(event.title).to eq('New Title')
      end

      it 'redirects to the event' do
        put :update, params: { id: event.to_param, event: new_params }
        expect(response).to redirect_to(event_path(event))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { attributes_for(:event, title: nil) }

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: event.to_param, event: invalid_params }
        expect(response).to render_template(nil)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:event) { create(:event, user:) }

    context 'when a valid event id is provided' do
      it 'deletes the event' do
        @event = event
        initial_count = Event.count
        expect do
          delete :destroy, params: { id: @event.id }
          # end.to change(Event, :count).by(-1)
        end.to change(Event, :count).from(initial_count).to(initial_count - 1)
      end

      it 'redirects to the events index page' do
        delete :destroy, params: { id: event.id }
        expect(response).to redirect_to(events_path)
      end

      it 'sets a flash notice message' do
        delete :destroy, params: { id: event.id }
        expect(flash[:notice]).to eq('Event was successfully destroyed.')
      end
    end

    context 'when an invalid event id is provided' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect do
          delete :destroy, params: { id: 0 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'before_action :set_event' do
    let(:event) { create(:event, user:) }

    context 'when a valid event id is provided' do
      before do
        allow(controller).to receive(:params).and_return({ id: event.id })
        controller.send(:set_event)
      end

      it 'sets the @event instance variable' do
        expect(assigns(:event)).to eq(event)
      end
    end

    context 'when an invalid event id is provided' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect do
          allow(controller).to receive(:params).and_return({ id: 0 })
          controller.send(:set_event)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  describe '#calculate_seating_summary' do
    let(:event) { create(:event) }

    it 'calculates seating summary for each seat category' do
      create(:seat, event:, category: 'VIP', total_count: 50)
      create(:seat, event:, category: 'Regular', total_count: 100)

      create(:guest, event:, category: 'VIP', commited_seats: 5,
        alloted_seats: 10)
      create(:guest, event:, category: 'Regular', commited_seats: 15,
        alloted_seats: 20)
      create(:guest, event:, category: 'Regular', commited_seats: 3,
        alloted_seats: 5)

      seating_summary = event.calculate_seating_summary(event.id)

      expect(seating_summary).to match_array([
                                               {
                                                 category: 'VIP',
                                                 guests_count: 1,
                                                 committed_seats: 5,
                                                 allocated_seats: 10,
                                                 total_seats: 50
                                               },
                                               {
                                                 category: 'Regular',
                                                 guests_count: 2,
                                                 committed_seats: 18,
                                                 allocated_seats: 25,
                                                 total_seats: 100
                                               }
                                             ])
    end
  end
end
