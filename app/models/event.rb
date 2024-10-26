# frozen_string_literal: true

class Event < ApplicationRecord
  mount_uploader :event_avatar, AvatarUploader
  belongs_to :user

  has_many :seats, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :email_services, dependent: :destroy
  has_many :referrals, dependent: :destroy
  def calculate_seating_summary
    seating_summary = []

    self.seats.each do |seat|
      guests_in_category = self.guests.where(event_id:, category: seat.category, section: seat.section)
      committed_seats = guests_in_category.sum(:commited_seats)
      allocated_seats = guests_in_category.sum(:alloted_seats)
      total_seats = seat.total_count
      ticket_sold = 0 # TODO: replace with actual tickets sold

      seating_summary << {
        category: seat.category,
        guests_count: guests_in_category.count,
        committed_seats:,
        allocated_seats:,
        ticket_sold:,
        total_seats:
      }
    end

    seating_summary
  end
end
