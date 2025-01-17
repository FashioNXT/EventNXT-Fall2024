# frozen_string_literal: true

require 'rails_helper'
RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:seats) { create_list(:seat, 5, event: event) }
  let(:guests) { create_list(:guest, 5, event: event) }
  
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:event) { create(:event, user: user) }
    let(:guest1) { create(:guest, event: event) }
    let(:guest2) { create(:guest, event: event) }
    let(:seat1) { create(:seat, event: event) }
    let(:seat2) { create(:seat, event: event) }
    let(:referral1) { create(:referral, event: event, referred: true, email: 'refer1@example.com') }
    let(:referral2) { create(:referral, event: event, referred: true, email: 'refer2@example.com') } 
    
    let(:ticket_sales_validator) { instance_double(TicketSalesValidatorService) }

    before do 
      allow_any_instance_of(Event).to receive(:calculate_seating_summary).and_return("summary data")
      allow_any_instance_of(Event).to receive(:update_referral_data).and_return("referral data")

      allow(TicketSalesValidatorService).to receive(:new).and_return(ticket_sales_validator)
      allow(ticket_sales_validator).to receive(:validate)
    end

    context 'assign values' do
      before do
        allow_any_instance_of(EventsController).to receive(:fetch_and_show_ticket_sales)
          .and_return(["external events", "ticket sales"])

        get :show, params: { id: event.id }
      end

      it 'assigns the correct event' do
        expect(assigns(:event)).to eq(event)
      end
      
      it 'assigns the seats of the event' do
        expect(assigns(:seats)).to match_array([seat1, seat2])
      end
  
      it 'assigns the guests of the event' do
        expect(assigns(:guests)).to match_array([guest1, guest2])
      end
      
      it 'asiigns the external events' do
        expect(assigns(:external_events)).to eq("external events") 
      end
      
      it 'assigns the ticket_sales' do
        expect(assigns(:ticket_sales)).to eq("ticket sales")
      end
      
      it 'assigns the seating summary' do
        expect(assigns(:seating_summary)).to eq("summary data")
      end

      it 'assigns the referral_data' do
        expect(assigns(:referral_data)).to eq("referral data")
      end 

      it 'returns a success response' do
        expect(response).to be_successful
      end
    end

    context 'when the tickets source is spreadhsheet,' do
      let(:event) { create(:event, user: user, ticket_source: Constants::TicketSales::Source::SPREADSHEET) }
      let(:ticket_sales) { ['sale1', 'sale2'] }
      let(:spreadsheet_service) { instance_double(TicketSalesSpreadsheetService) }

      before do
        allow(TicketSalesSpreadsheetService).to receive(:new).and_return(spreadsheet_service)
        allow(spreadsheet_service).to receive(:import_data).and_return(ticket_sales)
        
        get :show, params: { id: event.id }
      end

      it 'import tikcet_sales data' do
        expect(spreadsheet_service).to have_received(:import_data)
        expect(assigns(:ticket_sales)).to match_array(ticket_sales)
      end
      
      it 'validates ticket_sales data' do
        expect(ticket_sales_validator).to have_received(:validate)
      end

      it 'returns a success response' do
        expect(response).to be_successful
      end
    end

    context 'when the ticket source is eventbrite,' do
      let(:event) { create(:event, user: user, ticket_source: Constants::TicketSales::Source::EVENTBRITE) }
      let(:event_with_ext_id) { create(:event, :with_external_event_id, user: user) }
      let(:param_ext_id) { 'new_external_event_id' }
      let(:external_events) { ['id1', 'id2'] }
      let(:ticket_sales) { ['sale1', 'sale2'] } 

      before do
        allow(TicketVendor::Config).to receive(:new) do |args|
          instance_double(TicketVendor::Config, event_id: args[:event_id])
        end

        allow(TicketVendor::EventbriteHandlerService).to receive(:new) do |user, config| 
          instance_double(
            TicketVendor::EventbriteHandlerService,
            config: config,
            error_message: nil,
            authorized?: true,
            fetch_events: external_events,
            compose_ticket_sales: ticket_sales
          )
        end
      end
      
      context 'no external_id params provided' do
        before do
          get :show, params: { id: event.id }
        end
        it 'only show list of external events' do
          expect(assigns(:external_events)).to eq(external_events)
          expect(assigns[:ticket_sales]).to eq([])
          expect(response).to be_successful 
        end
      end
      
      context 'with external_event_id set in the database' do
        before do
          get :show, params: { id: event_with_ext_id.id }
        end
        it 'show list of external events and ticket sales' do
          expect(assigns(:external_events)).to eq(external_events)
          expect(assigns[:ticket_sales]).to eq(ticket_sales)
          expect(response).to be_successful 
        end
        
        it 'validates ticket_sales data' do
          expect(ticket_sales_validator).to have_received(:validate)
        end
      end

      context 'with external_event_id set in the params but not set in the db' do
        before do
          get :show, params: { id: event.id, external_event_id: param_ext_id }
        end

        it 'updates the event with new external_event_id' do
          expect(event.reload.external_event_id).to eq(param_ext_id)
        end
       
        it 'show list of external events and ticket sales' do
          expect(assigns(:external_events)).to eq(external_events)
          expect(assigns[:ticket_sales]).to eq(ticket_sales)
          expect(response).to be_successful  
        end 
        
        it 'validates ticket_sales data' do
          expect(ticket_sales_validator).to have_received(:validate)
        end
      end

      context 'with external_event_id in the params different from the one in the db' do
        before do
          get :show, params: { id: event_with_ext_id.id, external_event_id: param_ext_id }
        end

        it 'updates the event with new external_event_id' do
          expect(event_with_ext_id.reload.external_event_id).to eq(param_ext_id)
        end
       
        it 'show list of external events and ticket sales' do
          expect(assigns(:external_events)).to eq(external_events)
          expect(assigns[:ticket_sales]).to eq(ticket_sales)
          expect(response).to be_successful  
        end 
        
        it 'validates ticket_sales data' do
          expect(ticket_sales_validator).to have_received(:validate)
        end
      end

      context 'when there is an error message from eventbrite_service' do
        let(:error_message) {'Error fetching data' }
        before do
          allow(TicketVendor::EventbriteHandlerService).to receive(:new) do |user, config| 
            instance_double(
              TicketVendor::EventbriteHandlerService,
              config: config,
              error_message: error_message,
              authorized?: true,
              fetch_events: external_events,
              compose_ticket_sales: ticket_sales
            )
          end
          get :show, params: { id: event_with_ext_id.id }
        end
  
        it 'sets an alert flash message with the error' do
          expect(flash[:alert]).to eq(error_message)
          expect(response).to be_successful
        end

        it 'assigns the empty ticket_sales' do
          expect(assigns(:ticket_sales)).to match_array([])
        end
      end
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(event).to be_valid
    end

    it 'is not valid with an invalid ticket source' do
      event.ticket_source = 'invalid_source'
      expect(event).not_to be_valid
      expect(event.errors[:ticket_source]).to include('invalid_source is not a valid ticket source')
    end
  end
  
  describe '#calculate_seating_summary' do
    let(:ticket_sales) do
      [
        { Constants::TicketSales::Field::CATEGORY => 'VIP', Constants::TicketSales::Field::SECTION => 'A', tickets: 10 },
        { Constants::TicketSales::Field::CATEGORY => 'General', Constants::TicketSales::Field::SECTION => 'B', tickets: 20 },
        { Constants::TicketSales::Field::CATEGORY => 'VIP', Constants::TicketSales::Field::SECTION => 'A', tickets: 5 }
      ]
    end

    it 'returns an empty summary when there are no ticket sales' do
      summary = event.calculate_seating_summary([])

      expect(summary).to eq([])
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
end
