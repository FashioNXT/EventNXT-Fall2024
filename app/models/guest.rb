require('roo')

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
  validates :alloted_seats,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :commited_seats,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # validates :guest_commited, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # validate :allocated_seats_not_exceed_total

  # def allocated_seats_not_exceed_total
  #   if category.present? && event.present?
  #     seat = event.seats.find_by(category: category)
  #     if seat.present?
  #       existing_guest = event.guests.find_by(id: self.id)
  #       if existing_guest.present?
  #         total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats) - existing_guest.alloted_seats.to_i
  #         total_commited_seats = event.guests.where(category: category).sum(:commited_seats) - existing_guest.commited_seats.to_i
  #       else
  #         total_allocated_seats = event.guests.where(category: category).sum(:alloted_seats)
  #         total_commited_seats = event.guests.where(category: category).sum(:commited_seats)
  #       end
  #       remaining_allocated_seats = [0, seat.total_count - total_allocated_seats].max
  #       remaining_committed_seats = [0, total_allocated_seats + alloted_seats.to_i - total_commited_seats].max

  #       puts event.guests.where(category: category).sum(:alloted_seats)
  #       puts total_allocated_seats
  #       puts alloted_seats.to_i
  #       puts total_commited_seats

  #       if (total_allocated_seats + alloted_seats.to_i) > seat.total_count
  #         errors.add(:alloted_seats, "cannot exceed the total allocated seats (#{remaining_allocated_seats} remaining) for the category #{category}")
  #       end

  #       if (total_commited_seats + commited_seats.to_i) > total_allocated_seats + alloted_seats.to_i
  #         errors.add(:commited_seats, "cannot exceed the total allocated seats (#{remaining_committed_seats} remaining) for the category #{category}")
  #       end
  #     end
  #   end

  # end

  def self.validate_import(_spreadsheet)
    { status: true, message: 'Spreadsheet validated successfully' }
  end

  def self.import_spreadsheet(spreadsheet_file, event_id)
    # Validate file type
    unless ['.xlsx', '.xls', '.csv'].include?(File.extname(spreadsheet_file.original_filename))
      return { status: false, message: 'Invalid file type. Please upload a .xlsx, .xls, or .csv file.' }
    end
    spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)
  
    result = validate_import(spreadsheet)
    return result if result[:status] == false
  
    new_guests = []
    duplicate_emails = []
    empty_emails = []
    empty_categories = []
    empty_sections = []
    missing_seating_summary = []
    existing_guests = Guest.where(event_id: event_id).pluck(:email, :id).to_h
  
    # Iterate over each worksheet
    spreadsheet.sheets.each do |worksheet_name|
      worksheet = spreadsheet.sheet(worksheet_name)
  
      # Assuming the first row is headers, get the header row
      header = worksheet.row(1)
  
      (2..worksheet.last_row).each do |i|
        row = Hash[[header, worksheet.row(i)].transpose]
  
        first_name = row['First Name']
        last_name = row['Last Name']
        email = row['Email']
        affiliation = row['Affiliation']
        category = row['Category']
        section = row['Section']
        alloted_seats = row['Allotted Seats'].to_i
        commited_seats = row['Committed Seats'].to_i

        # Store the row number of the empty email
        if email.blank?
          empty_emails << i 
          next
        end
        # Store the row number of the empty category
        if category.blank?
          empty_categories << i
        end
        # Store the row number of the empty section
        if section.blank?
          empty_sections << i
          next
        end
        # unless Guest.category_and_section_present?(category, section, event_id)
        #   missing_seating_summary << { row: i, category: category, section: section }
        #   next
        # end

        if existing_guests[email]
          duplicate_emails << email
          next
        end
        guest = Guest.find_or_initialize_by(email: email, event_id: event_id)
        if guest.new_record?
          guest.assign_attributes(
            first_name: first_name,
            last_name: last_name,
            email: email,
            affiliation: affiliation,
            category: category,
            alloted_seats: alloted_seats,
            commited_seats: commited_seats,
            section: section,
            event_id: event_id
          )
        else
          duplicate_emails << email
          guest.assign_attributes(
            first_name: first_name,
            last_name: last_name,
            affiliation: affiliation,
            category: category,
            alloted_seats: alloted_seats,
            commited_seats: commited_seats,
            section: section
          )
        end
  
        begin
          guest.save!
          new_guests << guest
        rescue ActiveRecord::RecordInvalid => e
          result[:status] = false
          result[:message] = e.message
          return result
        end
      end
    end
    if missing_seating_summary.any?
      result[:status] = true
      missing_seating_summary_messages = missing_seating_summary.map do |entry|
        "Category and Section not found in Seating summary, '#{entry[:category]}', '#{entry[:section]}'"
      end
      result[:message] = missing_seating_summary_messages.join('. ')
    elsif empty_emails.any?
      result[:status] = true
      result[:message] = "Empty emails found at rows: #{empty_emails.join(', ')}"
    elsif duplicate_emails.any?
      result[:status] = true
      result[:message] = "Duplicate emails found: #{duplicate_emails.join(', ')}"
    elsif empty_categories.any?
      result[:status] = true
      result[:message] = "Empty categories found at rows: #{empty_categories.join(', ')}"
    elsif empty_sections.any?
      result[:status] = true
      result[:message] = "Empty sections found at rows: #{empty_sections.join(', ')}"
    else
      result[:status] = true
      result[:message] = "Guests imported successfully"
    end
  
    result[:guests] = new_guests
    result
  end

  private

  def generate_rsvp_link
    self.rsvp_link = SecureRandom.hex(20) # You can adjust the length as needed
  end
end
