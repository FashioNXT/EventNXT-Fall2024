class Seat < ApplicationRecord
  belongs_to :event

  # ===================================
  # required to have to pass Rspec tests
  validates :category, presence: true
  validates :section, presence: true
  validates :total_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # ===================================
end
