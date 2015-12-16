require 'forwardable'

module Spree
  module EasyPost
    # This is a wrapper class for +Spree::Shipment+ to encapsulate the
    # Easypost API used for creating +EasyPost::Shipment+.
    class Shipment
      extend Forwardable

      # The shipment used to initialize a +Spree::EasyPost::Shipment+.
      attr_reader :shipment

      def_delegators :@shipment, :ship_address, :stock_location, :to_package

      # Create a new instance of a +Spree::EasyPost::Shipment+.
      #
      # ===== Arguments
      # [+shipment+] A +Spree::Shipment+.
      #
      # ===== Examples
      #   Spree::EasyPost::Shipment.new spree_shipment
      #   # Returns a new instance of a +Spree::EasyPost+ object
      def initialize(shipment)
        @shipment = shipment
      end

      # Create or retrieves a new +EayPost::Shipment+ from the EasyPost API.
      #
      # ===== Examples
      # shipment = Spree::EasyPost::Shipment.new spree_shipment
      #   shipment.easypost_shipment
      #   # Returns an +EasyPost::Shipment+
      def easypost_shipment
        retrieve_easypost_shipment
      rescue ::EasyPost::Error
        create_easypost_shipment
      end

      # Purchase an easypost shipping label.
      #
      # ===== Examples
      #   shipment = Spree::EasyPost::Shipment.new spree_shipment
      #   shipment.easypost_shipment
      #   shipment.buy_easypost_rate
      #   # returns the easypost shipment with the label and tracking information
      def buy_easypost_label
        rate = easypost_shipment.rates.detect do |rate|
          rate.id == shipment.selected_shipping_rate.easy_post_rate_id
        end

        easypost_shipment.buy(rate)
        shipment.update tracking: easypost_shipment.tracking_code
        easypost_shipment.postage_label
      end

      private

      def shipment_params
        {
          to_address: Address.new(address: shipment.address).easypost_address,
          from_address: Address.new(stock_location: stock_location).easypost_address,
          parcel: Package.new(to_package).easypost_parcel
        }
      end

      def create_easypost_shipment
        @ep_shipment ||= ::EasyPost::Shipment.create(shipment_params)
      end

      def retrieve_easypost_shipment
        shipment_id = shipment.selected_shipping_rate.easy_post_shipment_id
        @ep_shipment ||= ::EasyPost::Shipment.retrieve shipment_id
      end
    end
  end
end
