# Model For Ticket Sales
class TicketSale < ApplicationRecord
  belongs_to :event

  # class instance variable
  REQUIRED_FIELDS = %i[email category section tickets amount].freeze

  # Model-level vaidations
  validates :email, presence: true, uniqueness: { scope: :event_id, case_sensitive: false }
  validates :category, presence: true
  validates :section, presence: true
  validates :tickets, presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :amount, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  # Custom validations
  validate :tickets_cannot_be_greater_than_remaining_seats

  # Downcase the email before saving
  before_save :downcase_email

  private

  def tickets_cannot_be_greater_than_remaining_seats
    validation = TicketSale.validate_incoming_tickets(event, tickets, category, section)
    return unless validation[:status] == false

    errors.add(:tickets, validation[:err_msgs].join(', '))
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  class << self
    def import_spreadsheet(event, spreadsheet_file)
      validation = self.validate_import(event, spreadsheet_file)
      return validation if validation[:status] == false

      err_msgs = []
      sales = self.collect_sales(spreadsheet_file)

      existing_sales = self.where(
        event_id: event.id,
        email: sales.map do |sale|
          sale[:email]
        end
      ).index_by(&:email)

      sales.each do |sale|
        sale[:event_id] = event.id
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

    def validate_import(event, spreadsheet_file)
      err_msgs = []

      # Validate headers
      validation = self.validate_headers(spreadsheet_file)
      if validation[:status] == false
        err_msgs.concat(validation[:err_msgs])
        return { status: false, err_msgs: }
      end

      # Validate sales
      sales = self.collect_sales(spreadsheet_file)
      validation = self.validate_sales(event, sales)
      err_msgs.concat(validation[:err_msgs]) if validation[:status] == false

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    def validate_incoming_tickets(event, tickets, category, section)
      err_msgs = []

      seats = event.seats.find_by(category:, section:)
      if seats.nil?
        err_msgs << "Seats for #{category}:#{section} do not exist."
        return { status: false, err_msgs: }
      end

      # TODO: Should be replace with event.seats.remaining_seats
      remaining_seats =
        seats.total_count - sum_tickets(event, category, section)
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

    # Private Class Methods
    private

    def sum_tickets(event, category, section)
      TicketSale.where(
        event_id: event.id, category:, section:
      ).sum(:tickets)
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
        missing_fields = REQUIRED_FIELDS - headers
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
      field_names = self.column_names.map(&:to_sym)
      sales = []

      spreadsheet.sheets.each do |worksheet_name|
        worksheet = spreadsheet.sheet(worksheet_name)
        # Assuming the first row is headers
        headers = self.normilize_headers(worksheet.row(1))
        # Not using each_row_streaming due to unpredicable behavior with empty cells
        (2..worksheet.last_row).each do |i|
          sale = Hash[[headers, worksheet.row(i)].transpose]
          sale = sale.select { |field, _value| field_names.include?(field) }
          # Convert to integer and float
          sale[:tickets] = sale[:tickets].to_i
          sale[:amount] = sale[:amount].to_f
          sales << sale
        end
      end
      Rails.logger.debug("Sales: #{sales.inspect}")
      sales
    end

    def validate_sales(event, sales)
      err_msgs = []

      # Check Required fields
      validation = validate_sales_with_required_fields(sales)
      return validation if validation[:status] == false

      # Check the emails are unique
      validation = validate_sales_with_unique_emails(sales)
      return validation if validation[:status] == false

      # Compute the offset of tickets in each category and section
      tickets_offset = self.compute_tickets_offset(event, sales)

      # Validate the number of tickets in each category and section
      tickets_offset.each do |category, sections|
        sections.each do |section, offset|
          validation = self.validate_incoming_tickets(event, offset, category, section)
          err_msgs.concat(validation[:err_msgs]) if validation[:status] == false
        end
      end

      if err_msgs.empty?
        { status: true, err_msgs: [] }
      else
        { status: false, err_msgs: }
      end
    end

    # Compute the offset of tickets in each category and section, taking into account
    # any existing records with the same email. The offset is computed by subtracting
    # the existing tickets from the new tickets in each category and section.
    def compute_tickets_offset(event, sales)
      tickets_offset = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      sales.each do |sale|
        existing_sale = self.find_by(event_id: event.id, email: sale[:email])
        #  New sale will overwrite any existing record with the same email.
        tickets_offset[existing_sale.category][existing_sale.section] -= existing_sale.tickets unless existing_sale.nil?
        tickets_offset[sale[:category]][sale[:section]] += sale[:tickets]
      end
      tickets_offset
    end

    def validate_sales_with_required_fields(sales)
      missing_fields = REQUIRED_FIELDS.select do |field|
        sales.any? { |sale| !sale.key?(field) || sale[field].nil? }
      end
      if missing_fields.empty?
        { status: true, err_msg: [] }
      else
        { status: false, err_msgs: ["Missing data in fields: #{missing_fields.join(', ')}"] }
      end
    end

    def validate_sales_with_unique_emails(sales)
      emails = sales.map { |sale| sale[:email].downcase }
      email_counts = emails.tally
      duplicated_emails = email_counts.select { |_email, count| count > 1 }.keys
      if duplicated_emails.empty?
        { status: true, err_msg: [] }
      else
        { status: false, err_msgs: ["Duplicate emails found: #{duplicated_emails.inspect}"] }
      end
    end
  end
end
