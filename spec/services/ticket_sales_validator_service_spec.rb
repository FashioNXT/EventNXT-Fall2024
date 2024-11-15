require 'rails_helper'

RSpec.describe TicketSalesValidatorService, type: :service do
  FLAGS = Constants::TicketSales::Flags

  let(:seats) do 
    [
      create(:seat, category: 'VIP', section: 'A'),
      create(:seat, category: 'Regular', section: 'B'),
      create(:seat, category: 'VIP', section: 'C')
    ]
  end

  let(:event) do 
    create(:event, seats: seats)
  end

  describe '#validate' do
    let(:validator) { intance_double(TicketSalesValidatorService.new(event)) }
    before do
      allow(validator).to receive(:validate_category_section)
      validator.validate(valid_ticket_sales)
      expect(validator).to have_received(:validate_category_section)
    end
  end

  describe '#validate_category_section' do
    let(:valid_ticket_sales) do
      [
        { category: 'VIP', section: 'A' },
        { category: 'Regular', section: 'B'}
      ]
    end

    let(:invalid_ticket_sales) do
      [
        { category: 'VIP', section: 'D'},  # Invalid section
        { category: 'Luxury', section: 'A'} # Invalid category
      ]
    end
    
    context 'when all ticket sales have valid categories and sections,' do
      it 'does not add any flags' do
        validator = TicketSalesValidatorService.new(event, ticket_sales: valid_ticket_sales)
        validator.validate_category_section

        valid_ticket_sales.each do |sale|
          expect(sale[:flags].to_a.include?(FLAGS::INVALID_CATEGORY_SECTION)).to be false       
        end
      end
    end

    context 'when ticket sales have invalid categories or sections,' do
      it 'adds the INVALID_CATEGORY_SECTION flag to invalid ticket sales' do
        validator = TicketSalesValidatorService.new(event, ticket_sales: invalid_ticket_sales)
        validator.validate_category_section

        invalid_ticket_sales.each do |sale|
          expect(sale[:flags].include?(FLAGS::INVALID_CATEGORY_SECTION)).to be true        
        end
      end
    end

    context 'when ticket sales have a mix of valid and invalid categories or sections' do
      it 'adds the INVALID_CATEGORY_SECTION flag only to invalid sales' do
        mixed_sales = valid_ticket_sales + invalid_ticket_sales
        validator = TicketSalesValidatorService.new(event, ticket_sales: mixed_sales)
        validator.validate_category_section

        valid_ticket_sales.each do |sale|
          expect(sale[:flags].to_a.include?(FLAGS::INVALID_CATEGORY_SECTION)).to be false
        end

        invalid_ticket_sales.each do |sale|
          expect(sale[:flags].include?(FLAGS::INVALID_CATEGORY_SECTION)).to be true
        end
      end
    end
  end
end