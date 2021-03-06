module Admin
  class WordpressLogsController < Admin::ApplicationController

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, :created_at),
        params.fetch(resource_name, {}).fetch(:direction, :desc),
      )
    end

    def valid_action?(name, resource = resource_class)
       %w[new create edit destroy].exclude?(name.to_s) && super
     end

    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = WordpressLog.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   WordpressLog.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
