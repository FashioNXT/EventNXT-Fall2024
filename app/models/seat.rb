class Seat < ApplicationRecord
  belongs_to :event
  validates :category, presence: true
  validates :section, presence: true
  validates :total_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Custom validation to ensure uniqueness of category and section within the same event
  validate :unique_category_and_section_within_event, on: :create

  private

  def unique_category_and_section_within_event
    return unless Seat.exists?(category:, section:, event_id:)

    errors.add(:base, 'These seats already exist for this event')
  end
end
