module Admin
  class DonationsController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
		  %w[edit new destroy show].exclude?(name.to_s) && super
    end

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, :created_at),
        params.fetch(resource_name, {}).fetch(:direction, :desc),
      )
    end
  end
end
