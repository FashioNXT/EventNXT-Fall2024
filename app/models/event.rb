class Event < ApplicationRecord
  mount_uploader :event_avatar, AvatarUploader
  belongs_to :user

  has_many :seats, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :ticket_sales, dependent: :destroy
  has_many :email_services, dependent: :destroy
  has_many :referrals, dependent: :destroy

  def calculate_seating_summary()
    seating_summary = []

    self.seats.each do |seat|
      guests_in_category = self.guests.where(category: seat.category, section: seat.section)
      committed_seats = guests_in_category.sum(:commited_seats)
      allocated_seats = guests_in_category.sum(:alloted_seats)
      booked_seats = self.ticket_sales.where(category: seat.category, section: seat.section).sum(:tickets)
      total_seats = seat.total_count

      seating_summary << {
        category: seat.category,
        section: seat.section,
        guests_count: guests_in_category.count,
        committed_seats:,
        allocated_seats:,
        remaining_seats: total_seats - allocated_seats - booked_seats
      }
    end

    seating_summary
  end
end
