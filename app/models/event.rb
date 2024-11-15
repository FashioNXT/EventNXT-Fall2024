# frozen_string_literal: true

# Model of events created by the user
class Event < ApplicationRecord
  mount_uploader :event_avatar, AvatarUploader
  mount_uploader :event_box_office, SpreadsheetUploader
  belongs_to :user

  has_many :seats, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :email_services, dependent: :destroy
  has_many :referrals, dependent: :destroy

  validates :ticket_source, inclusion: { in: [
    Constants::TicketSales::Source::SPREADSHEET,
    Constants::TicketSales::Source::EVENTBRITE
  ], message: '%<value>s is not a valid ticket source' }

  def calculate_seating_summary(ticket_sales)
    seating_summary = []

    # Fetch seats for the event
    seats = self.seats
    guests = self.guests

    # Initialize a hash to accumulate ticket sales data
    ticket_summary = Hash.new { |hash, key| hash[key] = { tickets_sold: 0 } }

    # Process ticket sales to accumulate data
    ticket_sales.each do |sale|
      category = sale[Constants::TicketSales::Field::CATEGORY]
      section = sale[Constants::TicketSales::Field::SECTION]

      ticket_summary[[category, section]][:tickets_sold] += sale[:tickets].to_i
    end

    # Iterate through each seat to build the summary
    seats.each do |seat|
      # Fetch guests in the same category and section
      guests_in_category = guests.where(category: seat.category, section: seat.section)

      # Use the correct column names
      committed_seats = guests_in_category.sum(:commited_seats) || 0
      allocated_seats = guests_in_category.sum(:alloted_seats) || 0

      # Add ticket sales data to the summary
      ticket_data = ticket_summary[[seat.category, seat.section]]

      tickets_sold = ticket_data[:tickets_sold]

      # Total seats for this category and section
      total_seats = seat.total_count || 0

      remaining_seats = total_seats - (tickets_sold + committed_seats)

      seating_summary << {
        category: seat.category,
        section: seat.section,
        guests_count: guests_in_category.count,
        total_seats:,
        allocated_seats:,
        commited_seats: committed_seats,
        tickets_sold:,
        remaining_seats:
      }
    end

    seating_summary
  end

  def update_referral_data(ticket_sales)
    referral_data = self.referrals

    referral_data.each do |referral|
      total_tickets = 0
      total_cost = 0
      ticket_sales.each do |sale|
        if referral.referred == sale[Constants::TicketSales::Field::EMAIL]
          total_tickets += sale[Constants::TicketSales::Field::TICKETS]
          total_cost += sale[Constants::TicketSales::Field::COST]
        end
      end

      referral.update(status: true, tickets: total_tickets, amount: total_cost) if total_tickets.positive?
    end

    referral_data.sort_by do |referral|
      [referral.referred, referral.email]
    end
  end
end
