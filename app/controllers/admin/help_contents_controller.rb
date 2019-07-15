module Admin
  class HelpContentsController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
      %w[show].exclude?(name.to_s) && super
    end

    def show_action?(name, resource = resource_class)
      %w[show].exclude?(name.to_s) && super
    end

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:sort, :id),
        params.fetch(resource_name, {}).fetch(:direction, :asc),
      )
    end

    def new
      resource = resource_class.new
      authorize_resource(resource)
    	if params[:section]
    		resource.help_section = HelpSection.find(params[:section])
    	end
      render locals: {
        page: Administrate::Page::Form.new(dashboard, resource),
      }
    end

    def show
      redirect_to admin_help_section_path(requested_resource.help_section_id)
    end
  end
end
