# frozen_string_literal: true

# Referral
class Referral < ApplicationRecord
  belongs_to :event
  belongs_to :guest
end
