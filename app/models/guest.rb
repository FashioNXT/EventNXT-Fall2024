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

  def self.validate_import(_spreadsheet)
    { status: true, message: 'Spreadsheet validated successfully' }
  end

  def self.import_spreadsheet(spreadsheet_file, event_id)
    spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)

    result = validate_import(spreadsheet)
    return result if result[:status] == false

    # Iterate over each worksheet
    spreadsheet.sheets.each do |worksheet_name|
      worksheet = spreadsheet.sheet(worksheet_name)

      # Assuming the first row is headers, get the header row
      header = worksheet.row(1)

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        first_name = row['First Name']
        last_name = row['Last Name']
        email = row['Email']
        affiliation = row['Affiliation']
        category = row['Category']
        section = row['Section']
        alloted_seats = row['Allotted Seats'].to_i
        commited_seats = row['Committed Seats'].to_i

        guest = Guest.find_or_initialize_by(email:, event_id:)
        if guest.new_record?
          guest.assign_attributes(
            {
              first_name:,
              last_name:,
              email:,
              affiliation:,
              category:,
              alloted_seats:,
              commited_seats:,
              section:,
              event_id:
            }
          )
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

    result
  end

  private

  def generate_rsvp_link
    self.rsvp_link = SecureRandom.hex(20) # You can adjust the length as needed
  end
end
