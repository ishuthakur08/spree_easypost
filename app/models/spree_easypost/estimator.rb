# This class is a replacement for the +Spree::Stock::Estimator+.
# It overrides the shipping_rates method to retrieve shipping rate from the
# EasyPost Api.
#
# Shipping rates require Shipping methods so the estimator
# will create a new shipping method for any rate if it cannot find one
# with +the admin_name+ "<carrier> <service>". These newly created shipping
# methods are visible on the backend only until they are otherwise updated.
#
# The cheapest shipping rate will be selected for the package by default
module Spree
  module EasyPost
    class Estimator < Stock::Estimator

      # Get available shipping rates from easy post for the package
      # Create new shipping methods if no method is found which matches
      # the rate carrier and service.
      # Select the cheapest shipping rate by default.
      #
      # === Examples
      # estimator = Spree::EasyPost::Estimator.new order
      # rates = estimator.shipping_rates(package)
      # # Returns the shipping rates which have been associated with
      # # the package.
      def shipping_rates(package)
        shipment = Package.new(package).easypost_shipment
        rates = shipment.rates.sort_by { |r| r.rate.to_i }

        rates.each do |rate|
          spree_rate = build_rate(rate)

          if spree_rate.shipping_method.frontend?
            package.shipping_rates << spree_rate
          end
        end

        selected_cheapest_rate(package)
        package.shipping_rates
      end

      private

      def find_or_create_shipping_method(rate)
        admin_name = unique_name(rate)

        Spree::ShippingMethod.find_or_create_by!(admin_name: admin_name) do |r|
          r.name = admin_name
          r.display_on = :back_end
          r.code = rate.service
          r.calculator = Spree::Calculator::Shipping::FlatRate.create
          r.shipping_categories = [Spree::ShippingCategory.first]
        end
      end

      def build_rate(rate)
        Spree::ShippingRate.new(
          name: unique_name(rate),
          cost: rate.rate,
          easy_post_shipment_id: rate.shipment_id,
          easy_post_rate_id: rate.id,
          shipping_method: find_or_create_shipping_method(rate)
        )
      end

      def selected_cheapest_rate(package)
        rate = package.shipping_rates.min_by(&:cost)
        rate.selected = true if rate
      end

      def unique_name(rate)
        "#{ rate.carrier } #{ rate.service }"
      end
    end
  end
end
