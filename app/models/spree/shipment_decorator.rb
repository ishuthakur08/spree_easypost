module Spree
  module ShipmentDecorator
    def self.prepended(mod)
      mod.state_machine.before_transition(
        to: :shipped,
        do: :buy_easypost_rate,
        if: -> { Spree::EasyPost::CONFIGS[:purchase_labels?] }
      )
    end

    def easypost_shipment
      if selected_easy_post_shipment_id
        @ep_shipment ||= ::EasyPost::Shipment.retrieve(selected_easy_post_shipment_id)
      else
        @ep_shipment = build_easypost_shipment
      end
    end

    private

    def selected_easy_post_rate_id
      selected_shipping_rate.easy_post_rate_id
    end

    def selected_easy_post_shipment_id
      selected_shipping_rate.easy_post_shipment_id
    end

    def build_easypost_shipment
      ::EasyPost::Shipment.create(
        to_address: address.easypost_address,
        from_address: stock_location.easypost_address,
        parcel: to_package.easypost_parcel
      )
    end

    def buy_easypost_rate
      unless selected_easy_post_shipment_id.present?
        easypost_shipment
        rate = @ep_shipment.lowest_rate
        debugger
        @ep_shipment.buy(rate: rate)
        self.tracking= @ep_shipment.tracking_code
        selected_shipping_rate.update_attributes(
          :easy_post_shipment_id => @ep_shipment.id,
          :easy_post_rate_id => rate.id
        )
        self.save!
      end
    end
  end
end

Spree::Shipment.prepend Spree::ShipmentDecorator
