require 'rails_helper'
RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) } # Create a user for authentication
  before do
    sign_in user # Sign in the user before running the tests
  end
  describe "GET #show" do
    it "returns a success response" do
    # Use the factory to create a sample event
    event = create(:event, user: user)
    # Perform your test using the created event
    get :show, params: { id: event.to_param }
    expect(response).to be_successful
    end
  end

  # describe "GET #index" do
  #   it "returns a success response" do
  #     get :index
  #     expect(response).to be_successful
  #   end
  # end

  # Newly Added
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
    it "assigns only the current user's events to @events" do
      other_user = create(:user)
      other_event = create(:event, user: other_user)
      user_event = create(:event, user: user)
      
      get :index
      expect(assigns(:events)).to include(user_event)
      expect(assigns(:events)).not_to include(other_event)
    end
  end

  describe "GET #show" do
    let(:event) { create(:event, user: user) }

    it "assigns @guests" do
      guest = create(:guest, event: event)
      get :show, params: { id: event.to_param }
      expect(assigns(:guests)).to include(guest)
    end

    it "assigns @seating_summary" do
      get :show, params: { id: event.to_param }
      expect(assigns(:seating_summary)).to be_an(Array)
    end

    it "assigns @guest_details" do
      guest = create(:guest, event: event)
      get :show, params: { id: event.to_param }
      expect(assigns(:guest_details)).to include(guest)
    end

    it "assigns @referral_data" do
      referral = create(:referral, event: event)
      get :show, params: { id: event.to_param }
      expect(assigns(:referral_data)).to include(referral)
    end
    it "returns a success response" do
      get :show, params: { id: event.to_param }
      expect(response).to be_successful
    end

    context "when the event has a box office spreadsheet uploaded" do
      let(:event_with_box_office) { create(:event, :with_box_office, user: user) }

      it "loads the box office spreadsheet" do
        get :show, params: { id: event_with_box_office.to_param }
        expect(assigns(:event_box_office_data)).not_to be_nil
      end
    end
  end

  # describe "GET #show" do
  #   let(:event) { create(:event, user: user) }

  #   it "returns a success response" do
  #     get :show, params: { id: event.to_param }
  #     expect(response).to be_successful
  #   end

  #   context "when the event has a box office spreadsheet uploaded" do
  #     let(:event_with_box_office) { create(:event, :with_box_office, user: user) }

  #     it "loads the box office spreadsheet" do
  #       get :show, params: { id: event_with_box_office.to_param }
  #       expect(assigns(:event_box_office_data)).not_to be_nil
  #     end
  #   end
  # end

  # Newly Added
  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    let(:event) { create(:event, user: user) }

    it "returns a success response" do
      get :edit, params: { id: event.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) { attributes_for(:event) }

      it "creates a new event" do
        puts(@event)
        expect {
          post :create, params: { event: valid_params }
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post :create, params: { event: valid_params }
        expect(response).to redirect_to(Event.last)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { attributes_for(:event, title: nil) }

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { event: invalid_params }
        expect(response).to render_template(nil)
      end
    end
  end

  describe "PUT #update" do
    let(:event) { create(:event, user: user) }

    context "with valid params" do
      let(:new_params) { attributes_for(:event, title: "New Title") }

      it "updates the requested event" do
        put :update, params: { id: event.to_param, event: new_params }
        event.reload
        expect(event.title).to eq("New Title")
      end

      it "redirects to the event" do
        put :update, params: { id: event.to_param, event: new_params }
        expect(response).to redirect_to(event_path(event))
      end
    end

    context "with invalid params" do
      let(:invalid_params) { attributes_for(:event, title: nil) }

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: event.to_param, event: invalid_params }
        expect(response).to render_template(nil)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:event) { create(:event, user: user) }

    context "when a valid event id is provided" do
      it "deletes the event" do
          @event = event
          initial_count = Event.count
        expect do
          delete :destroy, params: { id: @event.id }
        #end.to change(Event, :count).by(-1)
        end.to change(Event, :count).from(initial_count).to(initial_count - 1)
      end

      it "redirects to the events index page" do
        delete :destroy, params: { id: event.id }
        expect(response).to redirect_to(events_path)
      end

      it "sets a flash notice message" do
        delete :destroy, params: { id: event.id }
        expect(flash[:notice]).to eq("Event was successfully destroyed.")
      end
      it "destroys the requested event" do
        expect {
          delete :destroy, params: { id: event.to_param }
        }.to change(Event, :count).by(-1)
      end
    
      it "redirects to the events list" do
        delete :destroy, params: { id: event.to_param }
        expect(response).to redirect_to(events_url)
      end
    end

    context "when an invalid event id is provided" do
      it "raises an ActiveRecord::RecordNotFound error" do
        expect do
          delete :destroy, params: { id: 0 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe "before_action :set_event" do
    let(:event) { create(:event, user: user) }

    context "when a valid event id is provided" do
      before do
        allow(controller).to receive(:params).and_return({ id: event.id })
        controller.send(:set_event)
      end

      it "sets the @event instance variable" do
        expect(assigns(:event)).to eq(event)
      end
    end

    context "when an invalid event id is provided" do
      it "raises an ActiveRecord::RecordNotFound error" do
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
      seat1 = create(:seat, event: event, category: 'VIP', total_count: 50)
      seat2 = create(:seat, event: event, category: 'Regular', total_count: 100)

      guest1 = create(:guest, event: event, category: 'VIP', commited_seats: 5, alloted_seats: 10)
      guest2 = create(:guest, event: event, category: 'Regular', commited_seats: 15, alloted_seats: 20)
      guest3 = create(:guest, event: event, category: 'Regular', commited_seats: 3, alloted_seats: 5)

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

  describe "private methods" do
    describe "#calculate_seating_summary" do
      let(:event) { create(:event, user: user) }
      let!(:seat) { create(:seat, event: event, category: "VIP", total_count: 100) }
      let!(:guest) { create(:guest, event: event, category: "VIP", commited_seats: 5, alloted_seats: 10) }
  
      it "calculates seating summary correctly" do
        summary = controller.send(:calculate_seating_summary, event.id)
        expect(summary).to include(
          hash_including(
            category: "VIP",
            guests_count: 1,
            committed_seats: 5,
            allocated_seats: 10,
            total_seats: 100
          )
        )
      end
    end
  end
end
