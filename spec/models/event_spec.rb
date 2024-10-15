require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) } # Create a user for authentication
  let(:event) { create(:event, user:) }

  describe 'associations' do
    it { should have_many(:seats).dependent(:destroy) }
    it { should have_many(:guests).dependent(:destroy) }
  end

  # describe 'file uploads' do
  #   it { should mount_uploader(:event_avatar).with_options(presence: true) }
  #   it { should mount_uploader(:event_box_office).with_options(presence: true) }
  # end
end

# # spec/models/event_spec.rb
# require 'rails_helper'
# require 'carrierwave/test/matchers'

# RSpec.describe Event, type: :model do
#   include CarrierWave::Test::Matchers

#   let(:user) { create(:user) } # Create a user for authentication
#   let(:event) { create(:event, user: user) }
#   # before do
#   #   sign_in user # Sign in the user before running the tests
#   # end

#   describe 'avatar uploader' do
#     it 'should have an avatar uploader mounted' do
#       expect(event).to have_attached_file(:avatar)
#     end

#     it 'should validate the content type' do
#       expect(event).to validate_content_type_of(:avatar).allowing('image/png', 'image/jpg', 'image/jpeg')
#     end

#     it 'should validate the file size' do
#       expect(event).to validate_size_of(:avatar).less_than(5.megabytes)
#     end

#     it 'should store the avatar in the correct directory' do
#       expect(event.avatar.path).to start_with("#{Rails.root}/public/uploads/event/avatar/#{event.id}")
#     end

#     it 'should allow you to set the avatar' do
#       event.avatar = File.open(File.join(Rails.root, '/path/to/your/avatar.jpg'))
#       event.save!
#       expect(event.avatar).to be_present
#     end
#   end
# end
