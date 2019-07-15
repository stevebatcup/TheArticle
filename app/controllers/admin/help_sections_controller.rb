module Admin
  class HelpSectionsController < Admin::ApplicationController

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:sort, :id),
        params.fetch(resource_name, {}).fetch(:direction, :asc),
      )
    end
  end
end
