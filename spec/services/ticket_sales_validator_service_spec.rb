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
    let(:validator) { TicketSalesValidatorService.new(event, ticket_sales:) }

    before do
      allow(validator).to receive(:validate_category_section)
      validator.validate
    end

    context 'when ticket_sales is nil' do
      let(:ticket_sales) { nil }

      it 'does not call #validate_category_section' do
        expect(validator).to_not have_received(:validate_category_section)
      end
    end

    context 'when ticket_sales is empty' do
      let(:ticket_sales) { [] }

      it 'does not call #validate_category_section' do
        expect(validator).to_not have_received(:validate_category_section)
      end
    end

    context 'when ticket_sales is not nil and not empty' do
      let(:ticket_sales) { [{ category: 'VIP', section: 'A' }] }

      it 'calls #validate_category_section' do
        expect(validator).to have_received(:validate_category_section)
      end
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

    let(:validator) { TicketSalesValidatorService.new(event, ticket_sales:) }

    before do
      validator.validate_category_section
    end
    
    context 'when all ticket sales have valid categories and sections,' do
      let(:ticket_sales) { valid_ticket_sales }

      it 'does not add any flags' do
        valid_ticket_sales.each do |sale|
          expect(sale[:flags].to_a.include?(FLAGS::INVALID_CATEGORY_SECTION)).to be false       
        end
      end
    end

    context 'when ticket sales have invalid categories or sections,' do
      let(:ticket_sales) { invalid_ticket_sales }
      
      it 'adds the INVALID_CATEGORY_SECTION flag to invalid ticket sales' do
        invalid_ticket_sales.each do |sale|
          expect(sale[:flags].include?(FLAGS::INVALID_CATEGORY_SECTION)).to be true        
        end
      end
    end

    context 'when ticket sales have a mix of valid and invalid categories or sections' do
      let(:ticket_sales) { valid_ticket_sales + invalid_ticket_sales }

      it 'adds the INVALID_CATEGORY_SECTION flag only to invalid sales' do
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