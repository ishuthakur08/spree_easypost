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
  end
end

Spree::Shipment.prepend Spree::ShipmentDecorator
