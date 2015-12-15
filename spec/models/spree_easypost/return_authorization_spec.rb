require 'pry'
require 'spec_helper'

RSpec.describe Spree::EasyPost::ReturnAuthorization, :vcr do
  let(:auth) { described_class.new return_authorization }
  let(:return_authorization) do
    create :return_authorization  do |ra|
      ra.return_items << create(:return_item)
    end
  end
  let!(:shipping_method) { create :shipping_method, admin_name: 'USPS Priority' }

  before { create :store }

  describe '#easypost_shipment' do
    subject { auth.easypost_shipment }
    it { is_expected.to be_a EasyPost::Shipment }
  end

  describe '#return_label' do
    subject { auth.return_label shipment.rates.first }
    let(:shipment) { auth.easypost_shipment }

    it { is_expected.to be_a EasyPost::PostageLabel }
    it 'has the correct fields' do
      expect(subject).to have_attributes(
         object: "PostageLabel",
         date_advance: 0,
         integrated_form: "none",
         label_resolution: 300,
         label_size: "4x6",
         label_type: "default",
         label_url: "http://assets.geteasypost.com/postage_labels/labels/20151215/83e003f3992f4cf6af019839fab6152a.png",
         label_file_type: "image/png"
      )
    end
  end
end
