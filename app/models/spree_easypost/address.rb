require 'forwardable'

# This class is a wrapper for a +Spree::Address+ or a +Spree::StockLocation
# to provide a standard API for generating a +Easypost::Address+ for either
# of these classes.
module Spree
  module EasyPost
    class Address
      extend Forwardable

      # return the resource used to initialized the instance
      attr_reader :resource

      def_delegators :@resource, :address1, :address2, :city, :zipcode, :phone

      # Initialize a new instance of a +Spree::EasyPost::Address+
      #
      #  === Initialization Options
      #  [+address:+]:: A +Spree::Address+ object
      #  [+stock_location:+]:: A +Spree::StockLocation+ object
      #
      #  === Examples
      #  Spree::EasyPost::Address.new address: spree_address
      #  # returns a new instance of the +Spree::EasyPost::Address+ class
      def initialize(address: nil, stock_location: nil)
        @resource = address || stock_location
      end

      # Get an +EasyPost::Address+
      #
      # === Examples
      # address = Spree::EasyPost::Address.new address: spree_address
      # address.easypost_address
      # # returns an instance of the +EasyPost::Address+ representing
      # # +spree_address+
      def easypost_address
        ::EasyPost::Address.create address_params
      end

      private

      def address_params
        {
          name: name,
          company: company,
          street1: address1,
          street2: address2,
          city: city,
          state: state,
          country: country,
          zip: zipcode,
          phone: phone,
        }
      end

      def state
        resource.state ? resource.state.abbr : resource.state_name
      end

      def country
        resource.country.try!(:iso)
      end

      def name
        resource.try(:full_name)
      end

      def company
        resource.try(:company) || Spree::Store.current.name
      end
    end
  end
end
