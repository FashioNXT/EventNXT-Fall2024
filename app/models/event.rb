# frozen_string_literal: true

# Event
class Event < ApplicationRecord
  mount_uploader :event_avatar, AvatarUploader
  mount_uploader :event_box_office, SpreadsheetUploader
  belongs_to :user
  validate :event_avatar_validation
  # <!--===================-->
  # <!--to add nested scaffold-->
  has_many :seats, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :email_services, dependent: :destroy
  has_many :referrals, dependent: :destroy
  # <!--===================-->
  def calculate_seating_summary(event_id)
    seating_summary = []

    Seat.where(event_id:).each do |seat|
      guests_in_category = Guest.where(event_id:, category: seat.category)
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

  def update_seating_summary(seating_summary)
    seating_summary.each do |entry|
      seating_summary_record = Seat.find_by(event_id: id, category: entry[:category], section: entry[:section])
      next unless seating_summary_record

      seating_summary_record.update(
        commited_seats: entry[:commited_seats],
        alloted_seats: entry[:alloted_seats],
        remaining_seats: entry[:remaining_seats]
      )
    end
  end

  def event_avatar_validation
    if event_avatar.present?
      if event_avatar.size > 20.megabytes
        errors.add(:event_avatar, 'is too big, should be less than 20 MB')
      elsif !%w(image/jpeg image/png).include?(event_avatar.content_type)
        errors.add(:event_avatar, 'must be a JPEG or PNG')
      end
    end
  end
end
