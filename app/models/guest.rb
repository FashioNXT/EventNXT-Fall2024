require 'roo'

class Guest < ApplicationRecord

  belongs_to :event
  has_many :referrals, dependent: :destroy
  
  before_create :generate_rsvp_link
  
  # ===================================
  # required to have to pass Rspec tests
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :affiliation, presence: true
  validates :category, presence: true
  validates :section, presence: true
  validates :event_id, presence: true
  validates :alloted_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :commited_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  #validates :guest_commited, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :allocated_seats_not_exceed_total

  def self.new_guest(attributes = {})
    puts "Creating guest with data: first_name=#{attributes[:first_name]}, last_name=#{attributes[:last_name]}, event_id=#{attributes[:event_id]}"
    guest = Guest.new(attributes) #creates new guest
    guest#return guest
  end
  
  def checked_only_if_booked
    return if (booked || !checked)
    errors.add(:checked, "can't be true if guest hasn't booked")
  end

  def full_name
    "#{first_name} #{last_name}"
  end 
  
  
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

  def self.validate_import(spreadsheet)
    return {status: true, message: "Spreadsheet validated successfully"}
  end

  def self.import_spreadsheet(spreadsheet, event_id)
     result = self.validate_import(spreadsheet)
     if result[:status] == false
       return result
     end

     # Iterate over each worksheet
    spreadsheet.sheets.each do |worksheet_name| 
      worksheet = spreadsheet.sheet(worksheet_name)
      
      # Assuming the first row is headers, get the header row
      header = worksheet.row(1)

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        first_name = row["First Name"]
        last_name = row["Last Name"]
        email = row["Email"]
        affiliation = row["Affiliation"] 
        category = row["Category"]
        section = row["Section"]
        alloted_seats = row["Allotted Seats"].to_i
        commited_seats = row["Committed Seats"].to_i
  
        guest = Guest.find_or_initialize_by(email: email, event_id: event_id)
        if guest.new_record?
          guest.assign_attributes({
            first_name: first_name,
            last_name: last_name,
            email: email,
            affiliation: affiliation,
            category: category,
            alloted_seats: alloted_seats,
            commited_seats: commited_seats,
            section: section,
            event_id: event_id
          })
        end
        
        begin
          guest.save!
          result[:message] = "Guest #{guest.email} imported successfully"
        rescue ActiveRecord::RecordInvalid => e
          result[:status] = false
          result[:message] = e.message
        end
      end
    end

    return result
  end

private
  def generate_rsvp_link
    self.rsvp_link = SecureRandom.hex(20) # You can adjust the length as needed
  end
end
