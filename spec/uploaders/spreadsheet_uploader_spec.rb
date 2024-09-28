# require 'rails_helper'

# RSpec.describe SpreadsheetUploader, type: :uploader do
#   let(:spreadsheet) { create(:spreadsheet) }
#   let(:uploader) { SpreadsheetUploader.new(spreadsheet, :file) }

#   before do
#     SpreadsheetUploader.enable_processing = true
#     File.open('spec/fixtures/files/spreadsheet.xlsx') do |f|
#       uploader.store!(f)
#     end
#   end

#   after do
#     SpreadsheetUploader.enable_processing = false
#     uploader.remove!
#   end

#   context 'when uploading a spreadsheet file' do
#     it 'should store the file in the correct location' do
#       expect(uploader.store_dir).to eq("uploads/spreadsheet/file/#{spreadsheet.id}")
#     end

#     it 'should have the correct filename' do
#       expect(uploader.filename).to eq('spreadsheet.xlsx')
#     end

#     it 'should be of the correct content type' do
#       expect(uploader.content_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
#     end
#   end
# end
#
# spec/uploaders/spreadsheet_uploader_spec.rb
# require 'rails_helper'
# require 'carrierwave/test/matchers'

# RSpec.describe SpreadsheetUploader, type: :uploader do
#   include CarrierWave::Test::Matchers

#   let(:user) { create(:user) } # Assuming you have a User factory

#   before do
#     SpreadsheetUploader.enable_processing = true
#     @uploader = SpreadsheetUploader.new(user, :avatar)
#     @uploader.store!(File.open('/mnt/c/Users/aduri/Desktop/se-working-dir/EventNXT/EventNXT_new_app/Book1.xlsx'))
#   end

#   after do
#     SpreadsheetUploader.enable_processing = false
#     @uploader.remove!
#   end

#   context 'direct file upload' do
#     it 'uploads a spreadsheet file' do
#       expect(@uploader).to be_truthy
#       expect(@uploader.file).to be_present
#       expect(@uploader.file.filename).to eq('Book1.xlsx')
#     end
#   end

#   context 'storage directory' do
#     it 'has the correct storage directory' do
#       expect(@uploader.store_dir).to eq("uploads/#{user.class.to_s.underscore}/avatar/#{user.id}")
#     end
#   end

# end
