require 'spec_helper'

RSpec.describe Spree::EasyPost::Shipment, :vcr do
  let(:shipment) { described_class.new spree_shipment }
  let(:spree_shipment) { create :shipment }

  describe '#easypost_shipment' do
    subject { shipment.easypost_shipment }

    shared_examples 'an EasyPost shipment' do
      it { is_expected.to be_a EasyPost::Shipment }

      it 'is a shipment object' do
        expect(subject.object).to eq 'Shipment'
      end
    end

    context 'when the shipment is new' do
      it_behaves_like 'an EasyPost shipment'

      it 'creates a new shipment' do
        expect(EasyPost::Shipment).to receive(:create).and_call_original
        subject
      end
    end

    context 'when the shipment has been created' do
      before do
        id = described_class.new(spree_shipment).easypost_shipment.id

        allow_any_instance_of(Spree::ShippingRate).
          to receive(:easy_post_shipment_id).
          and_return(id)
      end

      it_behaves_like 'an EasyPost shipment'

      it 'retrieves an existing shipment' do
        expect(EasyPost::Shipment).to receive(:retrieve).and_call_original
        subject
      end

      it 'does not create a new shipment' do
        expect(EasyPost::Shipment).to_not receive(:create)
        subject
      end
    end
  end

  describe '#buy_easypost_label' do
    subject { shipment.buy_easypost_label }

    before do
      id = shipment.easypost_shipment.rates.first.id

      allow_any_instance_of(Spree::ShippingRate).
        to receive(:easy_post_rate_id).
        and_return(id)
    end

    it { is_expected.to be_a EasyPost::PostageLabel }

    it 'sets the shipment tracking code' do
      subject
      tracking_number = spree_shipment.reload.tracking
      expect(tracking_number).to eq '9499907123456123456781'
    end
  end
end
