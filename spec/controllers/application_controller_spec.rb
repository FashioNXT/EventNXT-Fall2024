# frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe ApplicationController, type: :controller do
#   describe '#after_sign_in_path_for' do
#     let(:user) { create(:user) } # Assuming you have a User factory set up

#     it 'redirects to events_path for a signed-in user' do
#       sign_in user
#       expect(controller.after_sign_in_path_for(user)).to eq(events_path)
#     end

#     it 'falls back to super for other resources' do
#       resource = double('SomeOtherResource')
#       expect(controller.after_sign_in_path_for(resource)).to eq(super())
#     end

#     it 'logs an error and falls back to super when an exception occurs' do
#       allow(controller).to receive(:events_path).and_raise(RuntimeError, 'Some error message')

#       expect(Rails.logger).to receive(:error).with(/Error in after_sign_in_path_for: Some error message/)
#       expect(controller.after_sign_in_path_for(user)).to eq(super())
#     end
#   end
# end
