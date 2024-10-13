# Model For Ticket Sales
class TicketSale < ApplicationRecord
  belongs_to :event

  # class instance variable
  REQUIRED_FIELDS = %i[email category section tickets amount].freeze

  # Model-level uniqueness validation (case-insensitive)
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Model-level validations
  validates :category, presence: true
  validates :section, presence: true
  validates :tickets, presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :amount, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  # Custom validations
  validate tickets_cannot_be_greater_than_remaining_seats

  class << self
    def validate_import(spreadsheet_file)
      err_msgs = []

      # Validate headers
      validation = self.validate_headers(spreadsheet_file)
      if validation[:status] == false
        err_msgs.concat(validation[:err_msgs])
        return { status: false, err_msgs: }
      end

      # Validate sales
      sales = self.collect_sales(spreadsheet_file)
      validation = self.validate_sales(sales)
      err_msgs.concat(validation[:err_msgs]) if validation[:status] == false

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    def import_spreadsheet(spreadsheet_file)
      validation = self.validate_import(spreadsheet_file)
      return validation if validation[:status] == false

      spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)
      err_msgs = []
      sales = self.collect_sales(spreadsheet)

      existing_sales = self.where(
        email: sales.map do |sale|
          sale[:email]
        end
      ).index_by(&:email)

      sales.each do |sale|
        if existing_sales[sale[:email]].nil?
          self.create(sale)
        else
          existing_sales[sale[:email]].update(sale)
        end
      end

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    # Private Class Methods
    private

    def tickets_cannot_be_greater_than_remaining_seats
      validation = self.validate_incoming_tickets(tickets, category, section)
      return unless validation[:status] == false

      errors.add(:tickets, validated[:err_msgs].join(', '))
    end

    def sum_tickets(category, section)
      self.where(category:, section:).sum(:tickets)
    end

    def validate_incoming_tickets(tickets, category, section)
      err_msgs = []

      seats = event.seats.find_by(category:, section:)
      if seats.nil?
        err_msgs << "Seats for #{category}:#{section} do not exist."
        return { status: false, err_msgs: }
      end

      # TODO: Should be replace with event.seats.remaining_seats
      remaining_seats = eats.total_count
      if remaining_seats < tickets
        err_msgs << "Not enough seats available for #{category}:#{section}"
      elsif tickets.negative? && remaining_seats - tickets > seats.total_count
        err_msgs << "Available seats for #{category}:#{section} exceed total capacity."
      end

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    def validate_sales(sales)
      err_msgs = []

      # Check the emails are unique
      unique_emails = sales.map { |sale| sale[:email] }.uniq
      if unique_emails.size != sales.size
        err_msgs << 'Duplicate email found in sales.'
        return { status: false, err_msgs: }
      end

      # Compute the offset of tickets in each category and section
      tickets_offset = compute_tickets_offset(sales)

      # Do the validation
      tickets_offset.each do |category, sections|
        sections.each do |section, offset|
          validation = self.validate_incoming_tickets(offset, category, section)
          err_msgs.concat(validation[:err_msgs]) if validation[:status] == false
        end
      end

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    def compute_tickets_offset(sales)
      tickets_offset = {}
      sales.each do |sale|
        record = self.find_by(sale[:email])
        #  New sale will overwrite any existing record with the same email.
        unless record.nil?
          tickets_offset[record.category][record.section] -= record.tickets
        end
        tickets_offset[sale[:category]][sale[:section]] += tickets
      end
      tickets_offset
    end

    def normilize_headers(headers)
      headers.map do |header|
        header.downcase.gsub(' ', '_').to_sym
      end
    end

    def validate_headers(spreadsheet_file)
      spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)
      err_msgs = []

      spreadsheet.sheets.each do |worksheet_name|
        worksheet = spreadsheet.sheet(worksheet_name)
        # Assuming the first row is headers
        headers = self.normilize_headers(worksheet.row(1))
        missing_fields = self.class.REQUIRED_FIELDS - headers
        next if missing_fields.empty?

        err_msg = "Missing fields on worksheet '#{worksheet_name}': "
        err_msg << missing_fields.join(', ')
        err_msgs << err_msg
      end

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    def collect_sales(spreadsheet_file)
      spreadsheet = Roo::Spreadsheet.open(spreadsheet_file.path)
      sales = []

      spreadsheet.sheets.each do |worksheet_name|
        worksheet = spreadsheet.sheet(worksheet_name)
        # Assuming the first row is headers
        headers = self.normilize_headers(worksheet.row(1))
        worksheet.each(2..worksheet.last_row) do |row|
          sale = Hash[[headers, row].transpose]
          sales << sale
        end
      end
      sales
    end
  end
end
