require File.expand_path('../../../spree_easypost/estimator', __FILE__)
module Spree
  module Stock
    module CoordinatorDecorator
      def self.prepended(mod)
        mod.cattr_accessor :estimator_class
        mod.estimator_class = Spree::EasyPost::Estimator
      end

      private

      def estimate_packages(packages)
        estimator = estimator_class.new(order)

        packages.each do |package|
          package.shipping_rates = estimator.shipping_rates(package)
        end
      end
    end

    Coordinator.prepend CoordinatorDecorator
  end
end
