require 'forwardable'

# A wrapper class for +Spree::Package+ to encapsulate the API calls
# to Easypost to retrieve +EasyPost::Parcel+ and +EasyPost::Shipment+
module Spree
  module EasyPost
    class Package
      extend Forwardable

      # Retrieve the +Spree::Package+
      attr_reader :package

      def_delegators :@package, :order, :stock_location

      # Initialize a new instance of a +Spree::EasyPost::Package
      #
      # === Attributes
      # [+package+]:: A +Spree::Package+ the weight of the package must
      #               not be 0 or EasyPost will raise an error.
      #
      # === Examples
      # Spree::EasyPost::Package.new package
      # # Returns and instance of +Spree::EasyPost::Package+
      def initialize(package)
        @package = package
      end

      # Retrieve an +EasyPost::Parcel
      #
      # === Examples
      # package = Spree::EasyPost::Package.new package
      # package.easypost_parcel
      # # Returns and instance of an EasyPost::Parcel
      def easypost_parcel
        ::EasyPost::Parcel.create weight: total_weight
      end

      # Retrieve an +EasyPost::Shipment
      #
      # === Examples
      # package = Spree::EasyPost::Package.new package
      # package.easypost_shipment
      # # Returns and instance of an EasyPost::Shipment
      def easypost_shipment
        ::EasyPost::Shipment.create shipment_params
      end

      private

      def total_weight
        package.contents.sum do |item|
          item.quantity * item.variant.weight
        end
      end

      def shipment_params
        {
          to_address: Address.new(address: order.ship_address).easypost_address,
          from_address: Address.new(stock_location: stock_location).easypost_address,
          parcel: easypost_parcel
        }
      end
    end
  end
end
