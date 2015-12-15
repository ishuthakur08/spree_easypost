require 'spec_helper'

RSpec.describe Spree::EasyPost::Estimator, :vcr do
  let(:estimator) { described_class.new order }
  let(:order) { create :completed_order_with_totals }
  let(:package) { order.shipments.first.to_package }

  describe '#shipping_rates' do
    subject { estimator.shipping_rates(package) }

    context 'when the shipping methods do not exist' do
      it 'creates shipping methods' do
        expect { subject }.to change { Spree::ShippingMethod.count }.by 5
      end

      it 'creates shipping methods' do
        expect { subject }.to_not change { package.shipping_rates.count }
      end
    end

    context 'when 1 or more shipping methods exist' do
      before do
        create(
          :shipping_method,
          admin_name: 'USPS First',
          display_on: display_on
        )
      end

      context 'when shipping methods can be displayed' do
        let(:display_on) { 'front_end' }

        it 'creates shipping methods' do
          expect { subject }.to change { Spree::ShippingMethod.count }.by 4
        end

        it 'creates shipping methods' do
          expect { subject }.to change { package.shipping_rates.count }.by 1
        end
      end

      context 'when no shipping methods can be displayed' do
        let(:display_on) { 'back_end' }

        it 'creates shipping methods' do
          expect { subject }.to change { Spree::ShippingMethod.count }.by 4
        end

        it 'creates shipping methods' do
          expect { subject }.to_not change { package.shipping_rates.count }
        end
      end
    end
  end
end
