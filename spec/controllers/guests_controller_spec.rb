# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe GuestsController, type: :controller do
  let(:user) { create(:user) } 
  let(:event) { create(:event, user:) }

  before do
    sign_in user 
  end

  let(:valid_attributes) { attributes_for(:guest, event_id: event.id) }
  let(:invalid_attributes) do
    attributes_for(:guest, first_name: nil, event_id: event.id)
  end

  describe 'GET #index' do
    it 'assigns all guests of the event as @guests' do
      guest1 = create(:guest, event:)
      guest2 = create(:guest, event:)
      get :index, params: { event_id: event.to_param }
      expect(assigns(:guests)).to eq([guest1, guest2])
    end

    it 'renders the :index template' do
      get :index, params: { event_id: event.to_param }
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested guest as @guest' do
      guest = create(:guest, event:)
      get :show, params: { event_id: event.to_param, id: guest.to_param }
      expect(assigns(:guest)).to eq(guest)
    end

    it 'renders the :show template' do
      guest = create(:guest, event:)
      get :show, params: { event_id: event.to_param, id: guest.to_param }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new guest as @guest' do
      get :new, params: { event_id: event.to_param }
      expect(assigns(:guest)).to be_a_new(Guest)
    end

    it 'renders the :new template' do
      get :new, params: { event_id: event.to_param }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested guest as @guest' do
      guest = create(:guest, event:)
      get :edit, params: { event_id: event.to_param, id: guest.to_param }
      expect(assigns(:guest)).to eq(guest)
    end

    it 'renders the :edit template' do
      guest = create(:guest, event:)
      get :edit, params: { event_id: event.to_param, id: guest.to_param }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new guest' do
        expect do
          post :create, params: { event_id: event.id, guest: valid_attributes }
        end.to change(Guest, :count).by(1)
      end

      it 'redirects to the created guest' do
        post :create, params: { event_id: event.id, guest: valid_attributes }
        expect(response).to redirect_to(event_path(event))
      end
    end

    context 'with invalid params' do
      it 'does not create a new guest' do
        expect do
          post :create,
            params: { event_id: event.id, guest: invalid_attributes }
        end.to_not change(Guest, :count)
      end

      it 'renders the new template' do
        post :create, params: { event_id: event.id, guest: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let!(:guest) { create(:guest, event:) }

    context 'with valid parameters' do
      it 'updates the requested guest' do
        put :update,
          params: { event_id: event.to_param, id: guest.to_param,
                    guest: { first_name: 'Updated', last_name: 'Guest' } }
        guest.reload
        expect(guest.first_name).to eq('Updated')
        expect(guest.last_name).to eq('Guest')
      end

      it 'redirects to the guest' do
        put :update,
          params: { event_id: event.id, id: guest.id,
                    guest: { first_name: 'Updated', last_name: 'Guest' } }
        expect(response).to redirect_to(event_path(event))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the guest' do
        put :update,
          params: { event_id: event.id, id: guest.id,
                    guest: { first_name: nil, last_name: 'Guest1' } }
        guest.reload
        expect(guest.first_name).to_not be_nil
        expect(guest.last_name).to_not eq('Guest1')
      end

      it 're-renders the edit method' do
        put :update,
          params: { event_id: event.id, id: guest.id,
                    guest: { first_name: nil, last_name: 'Guest' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:guests) do
      FactoryBot.create_list(:guest, 1, :guest1)
      FactoryBot.create_list(:guest, 1, :guest2)
      FactoryBot.create_list(:guest, 1, :guest3)
    end

    it 'destroys the requested guest' do
      initial_count = Guest.count
      expect do
        delete :destroy, params: { event_id: event.id, id: guests.first.id }
      end.to change(Guest, :count).from(initial_count).to(initial_count - 1)
    end

    it 'redirects to the guests list' do
      delete :destroy, params: { event_id: event.id, id: guests.first.id }
      expect(response).to redirect_to(event_guests_path(event))
    end
  end

  describe 'before_action :set_guest' do
    let!(:guest) { create(:guest, event:) }

    context 'when a valid guest id is provided' do
      before do
        allow(controller).to receive(:params).and_return({ id: guest.id })
        controller.send(:set_guest)
      end

      it 'sets the @guest instance variable' do
        expect(assigns(:guest)).to eq(guest)
      end
    end

    context 'when an invalid guest id is provided' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect do
          allow(controller).to receive(:params).and_return({ id: 0 })
          controller.send(:set_guest)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#book_seats' do
    # let(:guest) { create(:guest, rsvp_link: 'valid_rsvp_link') }
    let(:guest1) do
      Guest.create(first_name: 'Test', last_name: 'Guest', email: 'testguest@example.com', event:, affiliation: 'Friend',
        category: 'Adult', alloted_seats: 10, commited_seats: 10, guest_commited: 1, status: 'Confirmed', section: 1)
    end

    context 'when a valid RSVP link is provided' do
      before do
        get :book_seats, params: { rsvp_link: guest1.rsvp_link }
      end
      it 'sets the @guest instance variable' do
        expect(assigns(:guest)).to eq(guest1)
      end

      it 'renders the book_seats template' do
        expect(response).to render_template('book_seats')
      end

      it 'returns a successful response status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when an invalid RSVP link is provided' do
      before do
        get :book_seats, params: { rsvp_link: 'invalid_rsvp_link' }
      end

      it 'does not set the @guest instance variable' do
        expect(assigns(:guest)).to be_nil
      end

      it 'renders a plain text message for invalid RSVP link' do
        expect(response.body).to eq('Invalid RSVP link')
      end

      it 'returns a not_found response status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#update_commited_seats' do
    let(:guest) do
      Guest.create(first_name: 'Test', last_name: 'Guest', email: 'testguest@example.com', event:, affiliation: 'Friend',
        category: 'Adult', alloted_seats: 10, commited_seats: 0, guest_commited: 0, status: 'Confirmed', section: 1)
    end

    context 'when a valid RSVP link is provided' do
      it 'updates committed seats within the allocated limit' do
        post :update_commited_seats, params: {
          rsvp_link: guest.rsvp_link,
          guest: { commited_seats: 2 }
        }

        expect(assigns(:guest)).to eq(guest)
        expect(response).to redirect_to(book_seats_path(guest.rsvp_link))
        expect(flash[:notice]).to eq('Committed seats updated successfully.')
      end
    end

    context 'when attempting to exceed allocated seats' do
      it "does not update committed seats and renders 'book_seats'" do
        post :update_commited_seats, params: {
          id: guest.id, # Include the guest ID
          rsvp_link: guest.rsvp_link,
          guest: { commited_seats: 20 }
        }

        expect(assigns(:guest)).to eq(guest)
        expect(response).to render_template('book_seats')
        expect(flash[:alert]).to eq('Error: Total seats exceed allocated seats.')
      end
    end

    context 'when updating committed seats and save fails' do
      before do
        allow(Guest).to receive(:find_by).and_return(guest)
        allow(guest).to receive(:save).and_return(false)
        post :update_commited_seats, params: {
          id: guest.id, # Include the guest ID
          rsvp_link: 'valid_rsvp_link',
          guest: { commited_seats: 2 }
        }
      end

      it "renders 'book_seats' template" do
        expect(response).to render_template('book_seats')
      end
    end

    context 'when an invalid RSVP link is provided' do
      it 'renders plain text message for invalid RSVP link with not_found status' do
        post :update_commited_seats, params: {
          id: guest.id, # Include the guest ID
          rsvp_link: 'invalid_rsvp_link',
          guest: { commited_seats: 2 }
        }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq('Invalid RSVP link')
      end
    end
  end

  describe '#import_spreadsheet' do
    let(:event) { create(:event) }
    let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'guests.xlsx') }
    let(:duplicate_emails_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'guests_with_duplicate_emails.xlsx') }
    let(:empty_emails_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'guests_with_empty_emails.xlsx') }
    let(:empty_categories_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'guests_with_empty_categories.xlsx') }
    let(:empty_sections_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'guests_with_empty_sections.xlsx') }
    let(:spreadsheet_file) { Rack::Test::UploadedFile.new(file_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    let(:duplicate_emails_spreadsheet_file) { Rack::Test::UploadedFile.new(duplicate_emails_file_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    let(:empty_emails_spreadsheet_file) { Rack::Test::UploadedFile.new(empty_emails_file_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    let(:empty_categories_spreadsheet_file) { Rack::Test::UploadedFile.new(empty_categories_file_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    let(:empty_sections_spreadsheet_file) { Rack::Test::UploadedFile.new(empty_sections_file_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

    context 'without file' do
      it 'not call Guest#import_spreadsheet' do
        post :import_spreadsheet,
          params: { event_id: event.id, file: nil }

        expect(Guest).to_not receive(:import_spreadsheet)
      end

      it 'redirects to event path with error message' do
        post :import_spreadsheet, params: { event_id: event.id, file: nil }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:alert]).to eq('No file uploaded.')
      end
    end

    context 'with valid file' do
      before do
        allow(Guest).to receive(:import_spreadsheet).and_return({
          status: true,
          message: ''
        })
      end

      it 'calls Guest#import_spreadsheet once' do
        post :import_spreadsheet,
          params: { event_id: event.id, file: spreadsheet_file }

        expect(Guest).to have_received(:import_spreadsheet).once
      end

      it 'redirects to event path with success message' do
        allow(Guest).to receive(:import_spreadsheet).and_return({ status: true, message: 'Guests imported successfully' })

        post :import_spreadsheet, params: { event_id: event.id, file: spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:success]).to eq('Guests imported successfully')
      end
    end

    context 'with invalid file' do
      before do
        allow(Guest).to receive(:import_spreadsheet).and_return({
          status: false,
          message: 'fake error message'
        })
      end

      it 'redirects to event path with error message' do
        post :import_spreadsheet,
          params: { event_id: event.id, file: spreadsheet_file }

        expect(response).to redirect_to(event_path(event))
        expect(flash[:alert]).to eq('Invalid file format: fake error message')
      end
      it 'redirects to event path with alert message' do
        allow(Guest).to receive(:import_spreadsheet).and_return({ status: false, message: 'Invalid file format' })

        post :import_spreadsheet, params: { event_id: event.id, file: spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:alert]).to eq('Invalid file format: Invalid file format')
      end
    end

    context 'with duplicate emails' do
      it 'redirects to event path with warning message' do
        # Create existing guests with duplicate emails
        create(:guest, email: 'Anirith@sample.com', event: event)

        post :import_spreadsheet, params: { event_id: event.id, file: duplicate_emails_spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:warning]).to eq('Duplicate emails found: Anirith@sample.com')
      end
    end
    context 'with empty emails' do
      it 'redirects to event path with warning message' do
        post :import_spreadsheet, params: { event_id: event.id, file: empty_emails_spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:warning]).to eq('Empty emails found at rows: 2')
      end
    end

    context 'with empty categories' do
      it 'redirects to event path with warning message' do
        post :import_spreadsheet, params: { event_id: event.id, file: empty_categories_spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:warning]).to eq('Empty categories found at rows: 2')
      end
    end

    context 'with empty sections' do
      it 'redirects to event path with warning message' do
        post :import_spreadsheet, params: { event_id: event.id, file: empty_sections_spreadsheet_file }

        expect(response).to redirect_to(event_path(event.id))
        expect(flash[:warning]).to eq('Empty sections found at rows: 2')
      end
    end
  end
end
