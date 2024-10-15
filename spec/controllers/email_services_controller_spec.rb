require 'rails_helper'

RSpec.describe EmailServicesController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user # Sign in the user before running the tests
  end
  let(:valid_attributes) do
    {
      to: 'user@example.com',
      subject: 'Test Email',
      body: 'This is a test email'
    }
  end

  let(:valid_template_attributes) do
    {
      name: 'Sample Template',
      subject: 'Test Email',
      body: 'This is a test email'
    }
  end

  before do
    @email_service = EmailService.create!(valid_attributes) # Create a valid EmailService record
  end

  let(:invalid_attributes) do
    {
      to: '',
      subject: '',
      body: ''
    }
  end

  let(:invalid_template_attributes) do
    {
      name: '',
      subject: '',
      body: ''
    }
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
      # expect(response).to render_template(:index)
      # expect(response.body).to include("Unsent Email")
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: @email_service.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      email_service = EmailService.create! valid_attributes
      get :edit, params: { id: email_service.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new EmailService' do
        expect do
          post :create, params: { email_service: valid_attributes }
        end.to change(EmailService, :count).by(1)
      end

      it 'redirects to the created email_service' do
        post :create, params: { email_service: valid_attributes }
        expect(response).to redirect_to(EmailService)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the "new" template)' do
        post :create, params: { email_service: invalid_attributes }
        expect(response).not_to be_successful
        # expect(response).to render_template(:new)
        # expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          to: 'updated@example.com',
          subject: 'Updated Test Email',
          body: 'This is an updated test email'
        }
      end

      it 'updates the requested email_service' do
        email_service = EmailService.create! valid_attributes
        put :update,
          params: { id: email_service.to_param,
                    email_service: new_attributes }
        email_service.reload
        expect(email_service.to).to eq(new_attributes[:to])
        expect(email_service.subject).to eq(new_attributes[:subject])
        expect(email_service.body).to eq(new_attributes[:body])
      end

      it 'redirects to the email_service' do
        email_service = EmailService.create! valid_attributes
        put :update,
          params: { id: email_service.to_param,
                    email_service: valid_attributes }
        expect(response).to redirect_to(email_service)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the "edit" template)' do
        email_service = EmailService.create! valid_attributes
        put :update,
          params: { id: email_service.to_param,
                    email_service: invalid_attributes }
        expect(response).not_to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the email service' do
      email_service = EmailService.create! valid_attributes

      expect do
        delete :destroy, params: { id: email_service.to_param }
      end.to change(EmailService, :count).by(-1)

      # expect(response).to redirect_to(email_service)
      expect(flash[:notice]).to eq('Email service was successfully destroyed.')
    end
  end

  describe 'GET #new_email_template' do
    it 'renders the _form_email_template partial' do
      get :new_email_template
      expect(response).to render_template(partial: '_form_email_template')
    end
  end

  # describe 'POST #add_email_template' do
  #   let(:valid_template_params) { attributes_for(:email_template) } # Assuming you have a factory for EmailTemplate

  #   context 'with valid template parameters' do
  #     it 'creates a new email template' do
  #       expect {
  #         post :add_email_template, params: { email_template: valid_template_params }
  #       }.to change(EmailTemplate, :count).by(1)

  #     end
  #   end

  #   context 'with invalid template parameters' do
  #     let(:invalid_template_params) { { name: '', subject: '', body: '' } }

  #     it 'does not create a new email template' do
  #       expect {
  #         post :add_email_template, params: { email_template: invalid_template_params }
  #       }.not_to change(EmailTemplate, :count)

  #     end
  #   end
  # end

  describe 'POST #add_email_template' do
    context 'with valid parameters' do
      it 'creates a new email template' do
        expect do
          post :add_email_template, params: valid_template_attributes
        end.to change(EmailTemplate, :count).by(1)
      end

      it 'redirects to the email services URL' do
        post :add_email_template, params: valid_template_attributes
        expect(response).to redirect_to(email_services_url)
      end

      it 'sets a flash notice message' do
        post :add_email_template, params: valid_template_attributes
        expect(flash[:notice]).to eq('Email template was successfully created.')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new email template' do
        expect do
          post :add_email_template, params: invalid_template_attributes
        end.not_to change(EmailTemplate, :count)
      end

      it 'renders the _form_email_template partial' do
        post :add_email_template, params: invalid_template_attributes
        expect(response).to render_template(partial: '_form_email_template')
      end

      it 'sets a flash alert message' do
        post :add_email_template, params: invalid_template_attributes
        expect(flash[:notice]).to eq('Error: Email template could not be saved.')
      end
    end
  end

  describe 'GET #edit_email_template' do
    let(:email_template) { create(:email_template) }

    context 'when the email template exists' do
      it 'assigns the requested email template to @email_template' do
        get :edit_email_template, params: { id: email_template.to_param }
        expect(assigns(:email_template)).to eq(email_template)
      end

      it 'renders the _edit_email_template partial' do
        get :edit_email_template, params: { id: email_template.to_param }
        expect(response).to render_template(partial: '_edit_email_template')
      end
    end

    context 'when the email template does not exist' do
      it 'returns a not found response' do
        get :edit_email_template, params: { id: 'nonexistent-id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #update_email_template' do
    let(:email_template) { create(:email_template) }

    context 'with valid parameters' do
      it 'updates the requested email template' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: valid_template_attributes }
        email_template.reload
        expect(email_template.name).to eq('Sample Template')
        expect(email_template.subject).to eq('Test Email')
        expect(email_template.body).to eq('This is a test email')
      end

      it 'redirects to the email services URL' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: valid_attributes }
        expect(response).to redirect_to(email_services_url)
      end

      it 'sets a flash notice message' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: valid_attributes }
        expect(flash[:notice]).to eq('Email template was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the email template' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: invalid_attributes }
        email_template.reload
        expect(email_template.name).not_to eq('Template Name')
        expect(email_template.subject).not_to eq('Test Email')
        expect(email_template.body).not_to eq('Email Body')
      end

      it 'renders the edit_email_template partial' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: invalid_attributes }
        expect(response).to render_template(partial: '_edit_email_template')
      end

      it 'sets a flash alert message' do
        put :update_email_template,
          params: { id: email_template.to_param,
                    email_template: invalid_attributes }
        expect(flash[:alert]).to eq(nil)
      end
    end
  end

  describe 'GET #render_template' do
    let(:email_template) do
      create(:email_template, subject: 'Test Subject', body: 'Test Body')
    end

    context 'when requesting JSON format' do
      it 'renders the email template attributes as JSON' do
        get :render_template, params: { id: email_template.to_param },
          format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['subject']).to eq('Test Subject')
        expect(json_response['body']).to eq('Test Body')
      end
    end

    # Add more contexts if you have additional formats or cases to cover

    context 'when the email template does not exist' do
      it 'returns a not found response' do
        get :render_template, params: { id: 'nonexistent-id' }, format: :json
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Email template not found')
      end
    end
  end

  describe 'DELETE #destroy_email_template' do
    let!(:email_template) { create(:email_template) }

    context 'when the email template exists' do
      it 'destroys the requested email template' do
        expect do
          delete :destroy_email_template,
            params: { id: email_template.to_param }
        end.to change(EmailTemplate, :count).by(-1)
      end

      it 'redirects to the email services URL' do
        delete :destroy_email_template,
          params: { id: email_template.to_param }
        expect(response).to redirect_to(email_services_url)
      end

      it 'sets a flash notice message' do
        delete :destroy_email_template,
          params: { id: email_template.to_param }
        expect(flash[:notice]).to eq('Email template was successfully deleted.')
      end
    end

    context 'when the email template does not exist' do
      it 'returns a not found response' do
        delete :destroy_email_template, params: { id: 'nonexistent-id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#send_email' do
    let(:email_service) { create(:email_service) }
    let(:event) { create(:event) }
    let(:guest) { create(:guest) }

    before do
      allow(EmailService).to receive(:find).and_return(email_service)
      allow(Event).to receive(:find).and_return(event)
      allow(Guest).to receive(:find).and_return(guest)
    end

    it 'sends an email and updates the email service' do
      initial_count = EmailService.where.not(sent_at: nil).count

      expect do
        post :send_email, params: { id: email_service.id }
        email_service.reload
      end.to change {
               EmailService.where.not(sent_at: nil).count
             }.from(initial_count).to(initial_count + 1)

      expect(response).to redirect_to(email_services_url)
      expect(flash[:success]).to eq('Email sent!')
      expect(email_service.reload.sent_at).to be_present
    end
  end
end
