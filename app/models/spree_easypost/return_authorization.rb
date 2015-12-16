require 'forwardable'

module Spree
  module EasyPost
    # Encapsulates contacting the EasyPost API with a return authorization and returning
    # an +EasyPost::PostageLabel+.
    class ReturnAuthorization
      extend Forwardable

      # The +Spree::ReturnAuthorization+ used to initialize the instance.
      attr_reader :return_authorization

      def_delegators :@return_authorization, :stock_location, :order, :inventory_units

      # Get a new instance of the class.
      #
      # ===== Initialization Params
      # [+return_authorization+] A +Spree::ReturnAuthorization+.
      #
      # ===== Examples
      #   Spree::EasyPost::ReturnAuthorization.new return_authorization
      #   # returns a new instance of the class.
      def initialize(return_authorization)
        @return_authorization = return_authorization
      end

      # Create a new return shipment from the EasyPost API.
      #
      # ===== Examples
      #   return = Spree::EasyPost::ReturnAuthorization.new return_authorization
      #   return.easypost_shipment
      #   # returns an <EasyPost::Shipment>
      def easypost_shipment
        @ep_shipment ||= ::EasyPost::Shipment.create(
          from_address: Address.new(stock_location: stock_location).easypost_address,
          to_address: Address.new(address: order.ship_address).easypost_address,
          parcel: build_parcel,
          is_return: true
        )
      end

      # Create a return label from the EasyPost API.
      #
      # ===== Arguments
      # [+rate+] The +EasyPost::Rate+ to be purchased.
      #
      # ===== Examples
      #   return = Spree::EasyPost::ReturnAuthorization.new return_authorization
      #   return.return_label
      #   # returns an <EasyPost::PostageLabel>
      def return_label(rate)
        easypost_shipment.buy(rate) unless easypost_shipment.postage_label
        easypost_shipment.postage_label
      end

      private

      def build_parcel
        total_weight = inventory_units.joins(:variant).sum(:weight)
        ::EasyPost::Parcel.create weight: total_weight
      end
    end
  end
end
