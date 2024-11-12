require('roo')
# Guest
class Guest < ApplicationRecord
  belongs_to :event
  has_many :referrals, dependent: :destroy

  before_create :generate_rsvp_link

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

  def self.validate_import(_spreadsheet)
    { status: true, message: 'Spreadsheet validated successfully' }
  end

  def self.import_spreadsheet(spreadsheet_file, event_id)
    # Validate file type
    return { status: false, message: 'Invalid file type. Please upload a .xlsx, .xls, or .csv file.' } unless ['.xlsx', '.xls', '.csv'].include?(File.extname(spreadsheet_file.original_filename))

    spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)

    result = validate_import(spreadsheet)
    return result if result[:status] == false

    new_guests = []
    duplicate_emails = []
    empty_emails = []
    empty_categories = []
    empty_sections = []
    missing_seating_summary = []
    existing_guests = Guest.where(event_id:).pluck(:email, :id).to_h

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
        empty_categories << i if category.blank?
        # Store the row number of the empty section
        if section.blank?
          empty_sections << i
          next
        end

        if existing_guests[email]
          duplicate_emails << email
          next
        end
        guest = Guest.find_or_initialize_by(email:, event_id:)
        if guest.new_record?
          guest.assign_attributes(
            first_name:,
            last_name:,
            email:,
            affiliation:,
            category:,
            alloted_seats:,
            commited_seats:,
            section:,
            event_id:
          )
        else
          duplicate_emails << email
          guest.assign_attributes(
            first_name:,
            last_name:,
            affiliation:,
            category:,
            alloted_seats:,
            commited_seats:,
            section:
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
    result[:status] = true
    if missing_seating_summary.any?
      missing_seating_summary_messages = missing_seating_summary.map do |entry|
        "Category and Section not found in Seating summary, '#{entry[:category]}', '#{entry[:section]}'"
      end
      result[:message] = missing_seating_summary_messages.join('. ')
    elsif empty_emails.any?
      result[:message] = "Empty emails found at rows: #{empty_emails.join(', ')}"
    elsif duplicate_emails.any?
      result[:message] = "Duplicate emails found: #{duplicate_emails.join(', ')}"
    elsif empty_categories.any?
      result[:message] = "Empty categories found at rows: #{empty_categories.join(', ')}"
    elsif empty_sections.any?
      result[:message] = "Empty sections found at rows: #{empty_sections.join(', ')}"
    else
      result[:message] = 'Guests imported successfully'
    end

    result[:guests] = new_guests
    result
  end

  private

  def generate_rsvp_link
    self.rsvp_link = SecureRandom.hex(20) # You can adjust the length as needed
  end
end
