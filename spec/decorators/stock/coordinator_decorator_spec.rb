require 'spec_helper'

RSpec.describe Spree::Stock::Coordinator do
  let(:coordinator) { described_class.new create(:order_with_line_items) }

  describe '#packages' do
    subject { coordinator.packages }

    it 'calls the pluggable estimator' do
      expect(coordinator).to receive(:estimator_class).and_return(Spree::Stock::Estimator)
      subject
    end
  end
end
