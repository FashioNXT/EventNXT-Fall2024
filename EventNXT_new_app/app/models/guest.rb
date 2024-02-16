class Guest < ApplicationRecord
  belongs_to :event
  
  before_create :generate_rsvp_link
  
  # ===================================
  # required to have to pass Rspec tests
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :affiliation, presence: true
  validates :category, presence: true
  validates :event_id, presence: true
  validates :alloted_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :commited_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :guest_commited, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :allocated_seats_not_exceed_total

  def allocated_seats_not_exceed_total
    if category.present? && event.present?
      seat = event.seats.find_by(category: category)
      if seat.present?
        existing_guest = event.guests.find_by(id: self.id)
        if existing_guest.present?
          total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats) - existing_guest.alloted_seats.to_i
          total_commited_seats = event.guests.where(category: category).sum(:commited_seats) - existing_guest.commited_seats.to_i
        else
          total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats)
          total_commited_seats = event.guests.where(category: category).sum(:commited_seats)
        end
        remaining_allocated_seats = [0, seat.total_count - total_allocated_seats].max
        remaining_committed_seats = [0, total_allocated_seats + alloted_seats.to_i - total_commited_seats].max

        puts event.guests.where(category: category).sum(:alloted_seats)
        puts total_allocated_seats
        puts alloted_seats.to_i
        puts total_commited_seats
    
        if (total_allocated_seats + alloted_seats.to_i) > seat.total_count
          errors.add(:alloted_seats, "cannot exceed the total allocated seats (#{remaining_allocated_seats} remaining) for the category #{category}")
        end
    
        if (total_commited_seats + commited_seats.to_i) > total_allocated_seats + alloted_seats.to_i
          errors.add(:commited_seats, "cannot exceed the total allocated seats (#{remaining_committed_seats} remaining) for the category #{category}")
        end
      end
    end
    
  end
  # ===================================

  private

  def generate_rsvp_link
    random_string = SecureRandom.hex(6)
    self.rsvp_link = Rails.application.routes.url_helpers.book_seats_url(rsvp_link: random_string) # You can adjust the length as needed
  end
end
