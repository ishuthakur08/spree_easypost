require 'spec_helper'

RSpec.describe Spree::EasyPost::Package, :vcr do
  let(:package) { described_class.new spree_package }
  let(:weight) { 10.0 }

  let(:spree_package) do
    create :shipment do |s|
      s.inventory_units.flat_map(&:variant).each do |v|
        v.update weight: weight
      end
    end.
    to_package
  end

  describe '#easypost_parcel' do
    subject { package.easypost_parcel }

    it 'has the correct attributes' do
      expect(subject).to have_attributes(weight: weight)
    end
  end

  describe '#easypost_shipment' do
    subject { package.easypost_shipment }
    let(:expected_rates) do
      ["15.13", "3.07", "5.05", "5.70"]
    end

    it { is_expected.to be_a EasyPost::Shipment }

    it 'has the correct attributes' do
      expect(subject.object).to eq 'Shipment'
    end

    it 'has the correct rates' do
      rates = subject.rates.map(&:rate).sort
      expect(rates).to eq expected_rates
    end
  end
end
