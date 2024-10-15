require 'rails_helper'

RSpec.describe SeatsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, user:) }
  before do
    sign_in user # Sign in the user before running the tests
    # get_event event.id
  end

  describe 'GET #index' do
    # it "assigns all seats associated with the event to @seats" do
    #  seat1 = create(:seat, event: event)
    #  seat2 = create(:seat, event: event)
    #  get :index, params: { event_id: event.id }
    #  expect(assigns(:seats)).to match_array([seat1, seat2])
    # end

    it 'renders the index template' do
      get :index, params: { event_id: event.id }
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    let(:seat) { create(:seat, event:) }

    it 'assigns the requested seat to @seat' do
      get :show, params: { event_id: event.id, id: seat.id }
      expect(assigns(:seat)).to eq(seat)
    end

    it 'renders the show template' do
      get :show, params: { event_id: event.id, id: seat.id }
      expect(response).to render_template('show')
    end
  end

  describe 'GET #new' do
    it 'assigns a new seat associated with the event to @seat' do
      get :new, params: { event_id: event.id }
      expect(assigns(:seat)).to be_a_new(Seat).with(event_id: event.id)
    end

    it 'renders the new template' do
      get :new, params: { event_id: event.id }
      expect(response).to render_template('new')
    end
  end

  describe 'GET #edit' do
    let(:seat) { create(:seat, event:) }

    it 'assigns the requested seat to @seat' do
      get :edit, params: { event_id: event.id, id: seat.id }
      expect(assigns(:seat)).to eq(seat)
    end

    it 'renders the edit template' do
      get :edit, params: { event_id: event.id, id: seat.id }
      expect(response).to render_template('edit')
    end
  end

  describe 'POST #create' do
    let!(:user) { create(:user) }
    let!(:event) { create(:event, user:) }
    let(:seat) do
      Seat.create!(category: 'A', total_count: 10, event:, section: 1)
    end
    let(:valid_attributes) { { category: 'B', total_count: 10, section: 1 } }
    let(:invalid_attributes) { { total_count: -1 } }
    # @event = Event.find(params[:event_id])
    # let(:valid_params) { { seat: { category: 'A', total_count: 100, event_id: event.id } } }
    # let(:invalid_params) { { seat: { category: 'A', total_count: -1, event_id: event.id } } }

    context 'with valid parameters' do
      it 'creates a new seat' do
        expect do
          post :create,
            params: { event_id: event.id, id: seat.id, seat: valid_attributes }
        end.to change(Seat, :count).by(2)
      end

      it 'redirects to the index page with a success message' do
        post :create,
          params: { event_id: event.id, id: seat.id, seat: valid_attributes }
        expect(response).to redirect_to(event_path(event))
        expect(flash[:notice]).to eq('Seat was successfully created.')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new seat' do
        expect do
          post :create,
            params: { event_id: event.id, id: seat.id,
                      seat: invalid_attributes }
        end.to change(Seat, :count).by(1)
      end

      it 'renders the new template with an error message' do
        post :create,
          params: { event_id: event.id, id: seat.id, seat: invalid_attributes }
        expect(response).to render_template(:new)
        expect(assigns(:seat).errors.full_messages).to include('Total count must be greater than or equal to 0')
      end
    end
  end

  describe 'PUT #update' do
    let!(:user) { create(:user) }
    let!(:event) { create(:event, user:) }
    let(:seat) do
      Seat.create!(category: 'A', total_count: 10, event:, section: 1)
    end
    let(:valid_attributes) { { category: 'B' } }
    let(:invalid_attributes) { { category: nil } }

    context 'with valid params' do
      it 'updates the requested seat' do
        put :update,
          params: { event_id: event.id, id: seat.id, seat: valid_attributes }
        seat.reload
        expect(seat.category).to eq 'B'
      end

      it 'redirects to the seat' do
        put :update,
          params: { event_id: event.id, id: seat.id, seat: valid_attributes }
        expect(response).to redirect_to(event_seat_path(event, seat))
      end
    end

    context 'with invalid params' do
      it 'does not update the seat' do
        put :update,
          params: { event_id: event.id, id: seat.id, seat: invalid_attributes }
        seat.reload
        expect(seat.category).to eq 'A'
      end

      it 'returns an error response' do
        put :update,
          params: { event_id: event.id, id: seat.id, seat: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let!(:event) { create(:event, user:) }
    let!(:seat) do
      Seat.create(category: 'Test Category', total_count: 10, event_id: event.id,
        section: 1)
    end

    it 'destroys the requested seat' do
      expect do
        delete :destroy, params: { event_id: event.id, id: seat.to_param }
      end.to change(Seat, :count).by(-1)
    end

    it 'redirects to the seats list' do
      delete :destroy, params: { event_id: event.id, id: seat.to_param }
      expect(response).to redirect_to(event_seats_url(event))
    end
  end

  describe 'GET #show' do
    let!(:user) { create(:user) }
    let!(:event) { create(:event, user:) }
    let!(:user1) { create(:user) }
    let!(:other_event) { create(:event, user: user1) }
    let!(:seat) do
      Seat.create(category: 'Test Category', total_count: 10, event_id: event.id,
        section: 1)
    end

    it 'assigns the requested seat as @seat' do
      get :show, params: { event_id: event.id, id: seat.to_param }
      expect(assigns(:seat)).to eq(seat)
    end

    it 'raises an error if the seat does not belong to the specified event' do
      other_seat = Seat.create(category: 'Test Category', total_count: 10,
        event_id: other_event.id, section: 1)

      expect do
        get :show, params: { event_id: event.id, id: other_seat.to_param }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
