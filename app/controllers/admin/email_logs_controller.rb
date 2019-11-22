module Admin
  class EmailLogsController < Admin::ApplicationController

    before_action :authenticate_super_admin

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, :created_at),
        params.fetch(resource_name, {}).fetch(:direction, :desc),
      )
    end

    def valid_action?(name, resource = resource_class)
      %w[new create edit destroy].exclude?(name.to_s) && super
    end

    def scoped_resource
      if params[:user_id]
        resource_class.where(user_id: params[:user_id])
      else
        resource_class
      end
    end

  end
end
