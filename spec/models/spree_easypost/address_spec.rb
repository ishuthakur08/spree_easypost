require 'spec_helper'

RSpec.describe Spree::EasyPost::Address, :vcr do
  let(:address) { described_class.new attributes }

  describe '#easypost_address' do
    subject { address.easypost_address }

    context 'with a Spree::Address' do
      let(:attributes) { Hash[:address, spree_address] }
      let(:spree_address) { create :address }
      let(:address_attributes) do
        {
          name: 'John Doe',
          company: 'Company',
          street1: '215 N 7th Ave',
          street2: 'Northwest',
          city: 'Manville',
          zip: '08835',
          phone: '5555550199',
          state: 'NJ',
          country: 'US'
        }
      end

      it 'has the correct values' do
        expect(subject).to have_attributes(address_attributes)
      end
    end

    context 'with a Spree::StockLocation' do
      let(:attributes) { Hash[:stock_location, spree_stock_location] }
      let(:spree_stock_location) { create :stock_location }
      let(:address_attributes) do
        {
         company: 'Spree Test Store 1',
         street1: "131 S 8th Ave",
         city: "Manville",
         state: 'NJ',
         country: 'US',
         zip: "08835",
         phone: "2024561111",
        }
      end

      before { create :store }

      it 'has the correct values' do
        expect(subject).to have_attributes(address_attributes)
      end
    end
  end
end
