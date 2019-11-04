module Admin
  class ExchangesController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
      %w[new create edit destroy show].exclude?(name.to_s)
    end

    def order
      @order ||= Administrate::Order.new(
        params.fetch(:exchange, {}).fetch(:order, :follower_count),
        params.fetch(:exchange, {}).fetch(:direction, :desc),
      )
    end
  end
end
