# frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe AvatarUploader, type: :uploader do
#   let(:user) { create(:user) }
#   let(:uploader) { AvatarUploader.new(user, :avatar) }

#   before do
#     AvatarUploader.enable_processing = true
#     File.open('spec/fixtures/files/avatar.png') do |f|
#       uploader.store!(f)
#     end
#   end

#   after do
#     AvatarUploader.enable_processing = false
#     uploader.remove!
#   end

#   context 'when uploading an avatar file' do
#     it 'should store the file in the correct location' do
#       expect(uploader.store_dir).to eq("uploads/user/avatar/#{user.id}")
#     end

#     it 'should have the correct filename' do
#       expect(uploader.filename).to eq('avatar.png')
#     end

#     it 'should be of the correct content type' do
#       expect(uploader.content_type).to eq('image/png')
#     end

#     it 'should allow only certain file extensions' do
#       expect(uploader.extension_allowlist).to eq(%w(jpg jpeg gif png svg))
#     end
#   end
# end
#
# spec/uploaders/avatar_uploader_spec.rb
require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe AvatarUploader, type: :uploader do
  include CarrierWave::Test::Matchers

  let(:user) { create(:user) } # Assuming you have a User factory

  before do
    AvatarUploader.enable_processing = true
    @uploader = AvatarUploader.new(user, :avatar)
    @uploader.store!(File.open('/mnt/c/Users/aduri/Desktop/se-working-dir/EventNXT/EventNXT_new_app/some-dog.jpg'))
  end

  after do
    AvatarUploader.enable_processing = false
    @uploader.remove!
  end

  context 'direct file upload' do
    it 'uploads an image file' do
      expect(@uploader).to be_truthy
      expect(@uploader.file).to be_present
      expect(@uploader.file.filename).to eq('some-dog.jpg')
    end

    it 'has the expected content' do
      expected_content = File.read('/mnt/c/Users/aduri/Desktop/se-working-dir/EventNXT/EventNXT_new_app/some-dog.jpg')
      actual_content = File.read(@uploader.file.path)
      expect(actual_content).to eq(expected_content)
    end
  end

  context 'storage directory' do
    it 'has the correct storage directory' do
      expect(@uploader.store_dir).to eq("uploads/#{user.class.to_s.underscore}/avatar/#{user.id}")
    end
  end
end
