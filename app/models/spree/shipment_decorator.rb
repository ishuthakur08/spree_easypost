require File.expand_path('../../spree_easypost/estimator', __FILE__)

module Spree
  module ShipmentDecorator
    def self.prepended(mod)
      mod.state_machine.before_transition(
        to: :shipped,
        do: :buy_easypost_label,
        if: -> { Spree::EasyPost::CONFIGS[:purchase_labels?] }
      )
    end

    def buy_easypost_label
      EasyPost::Shipment.new(self).buy_easypost_label
    end

    def refresh_rates
      return shipping_rates if shipped? || order.completed?
      return [] unless can_get_rates?

      # StockEstimator.new assigment below will replace the current shipping_method
      original_shipping_method_id = shipping_method.try!(:id)

      new_rates = Stock::Coordinator.estimator_class.new(order).shipping_rates(to_package)

      # If one of the new rates matches the previously selected shipping
      # method, select that instead of the default provided by the estimator.
      # Otherwise, keep the default.
      selected_rate = new_rates.detect{ |rate| rate.shipping_method_id == original_shipping_method_id }
      if selected_rate
        new_rates.each do |rate|
          rate.selected = (rate == selected_rate)
        end
      end

      self.shipping_rates = new_rates
      self.save!

      shipping_rates
    end
  end
end

Spree::Shipment.prepend Spree::ShipmentDecorator
