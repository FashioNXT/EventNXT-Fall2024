class Event < ApplicationRecord
  mount_uploader :event_avatar, AvatarUploader
  belongs_to :user

  has_many :seats, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :ticket_sales, dependent: :destroy
  has_many :email_services, dependent: :destroy
  has_many :referrals, dependent: :destroy

  def calculate_seating_summary(event_id)
    seating_summary = []

    Seat.where(event_id:).each do |seat|
      guests_in_category = Guest.where(event_id:,
        category: seat.category)
      committed_seats = guests_in_category.sum(:commited_seats)
      allocated_seats = guests_in_category.sum(:alloted_seats)
      total_seats = seat.total_count

      seating_summary << {
        category: seat.category,
        guests_count: guests_in_category.count,
        committed_seats:,
        allocated_seats:,
        total_seats:
      }
    end

    seating_summary
  end
end
