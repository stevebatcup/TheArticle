module Admin
  class UsersController < Admin::ApplicationController

    def index
      search_term = params[:search].to_s.strip
      resources = Administrate::Search.new(scoped_resource,
                                           dashboard_class,
                                           search_term).run
      resources = apply_resource_includes(resources)
      resources = order.apply(resources)
      if params[:user]
        dir = params.fetch(:user).fetch(:direction)
        if params.fetch(:user).fetch(:order) == 'full_name'
          resources = resources.reorder("first_name #{dir}, last_name #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'human_created_at'
          resources = resources.reorder("created_at #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'admin_account_status'
          resources = resources.reorder("status #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'admin_profile_status'
          resources = resources.reorder("IF(status = 2, 1,(IF(has_completed_wizard = 1, (IF(status=1, 0, 3)), 2))) #{dir}")
        end
      end
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        search_term: search_term,
        page: page,
        show_search_bar: show_search_bar?,
      }
    end

    def add_to_blacklist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_blacklist("Blacklisted from admin", current_user)
            @status = :success
          else
            @status = :error
          end
        end
      end
    end

    def add_to_watchlist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_watchlist("Added from admin", current_user)
            @status = :success
          else
            @status = :error
          end
        end
      end
    end

    def deactivate
      if user = User.find_by(id: params[:user_id])
        user.deactivate
        @status = :success
      else
        @status = :error
      end
    end

    def reactivate
      if user = User.find_by(id: params[:user_id])
        user.reactivate
        @status = :success
      else
        @status = :error
      end
    end

    def destroy
      if user = User.find_by(id: params[:user_id])
        user.delete_account("Admin deleted account", true)
        @status = :success
        if params[:destroy]
          user.destroy
          redirect_to "/admin/users"
        end
      else
        @status = :error
      end
    end

    def records_per_page
      params[:per_page] || cookies.permanent[:admin_user_records_per_page] || 50
    end

    def set_records_per_page
      respond_to do |format|
        format.json do
          cookies.permanent[:admin_user_records_per_page] = params[:per_page]
        end
      end
    end

  private
    def order
      @order ||= begin
        orderParam = params.fetch(resource_name, {}).fetch(:order, :created_at)
        dirParam = params.fetch(resource_name, {}).fetch(:direction, :desc)
        Administrate::Order.new(orderParam, dirParam)
      end
    end

  end
end
