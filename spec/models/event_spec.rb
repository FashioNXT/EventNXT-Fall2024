# frozen_string_literal: true

require 'rails_helper'
require 'mini_magick'
require 'carrierwave/test/matchers'

RSpec.describe Event, type: :model do
  include CarrierWave::Test::Matchers

  before(:all) do
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = false
    end
  end

  after(:all) do
    CarrierWave.clean_cached_files!(0)
  end

  let(:event) { build(:event) }

  describe 'associations' do
    it { should have_many(:seats).dependent(:destroy) }
    it { should have_many(:guests).dependent(:destroy) }
  end

  describe 'validations' do
    context 'when event_avatar is attached' do
      it 'is valid with a JPEG image under 20 MB' do
        event.event_avatar = File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.jpg'))
        expect(event).to be_valid
      end

      it 'is valid with a PNG image under 20 MB' do
        event.event_avatar = File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.png'))
        expect(event).to be_valid
      end

      # it 'is invalid with a file size over 20 MB' do
      #   event.event_avatar = File.open(Rails.root.join('spec', 'fixtures', 'files', 'large_sample.jpg'))
      #   event.valid?
      #   expect(event.errors[:event_avatar]).to include('is too big, should be less than 20 MB')
      # end

      # it 'is invalid with a non-image file type' do
      #   event.event_avatar = File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.txt'))
      #   event.valid?
      #   expect(event.errors[:event_avatar]).to include('must be a JPEG or PNG')
      # end
    end
  end
end
