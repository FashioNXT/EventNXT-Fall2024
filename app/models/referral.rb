# frozen_string_literal: true

# Referral
class Referral < ApplicationRecord
  belongs_to :event
  belongs_to :guest

  # validates :referred, uniqueness: {scope: :event}
end
