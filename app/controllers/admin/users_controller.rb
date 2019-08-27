module Admin
  class UsersController < Admin::ApplicationController

    def index
      search_term = params[:search].to_s.strip
      @users = Administrate::Search.new(scoped_resource,
                                           dashboard_class,
                                           search_term).run
      @users = apply_resource_includes(@users)
      @users = order.apply(@users)
      if params[:user]
        dir = params.fetch(:user).fetch(:direction)
        if params.fetch(:user).fetch(:order) == 'full_name'
          @users = @users.reorder("first_name #{dir}, last_name #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'human_created_at'
          @users = @users.reorder("created_at #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'admin_account_status'
          @users = @users.reorder("status #{dir}")
        elsif params.fetch(:user).fetch(:order) == 'admin_profile_status'
          @users = @users.reorder("IF(status = 2, 1,(IF(has_completed_wizard = 1, (IF(status=1, 0, 3)), 2))) #{dir}")
        end
      end
      @users = @users.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      @search_start_date = "2019-03-13"
      @search_end_date = Date.today.strftime("%Y-%m-%d")

      render locals: {
        resources: @users,
        search_term: search_term,
        page: page
      }
    end

    def add_to_blacklist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_blacklist("Blacklisted from admin", current_user, user.email)
            user.delete_account("Admin deleted account", true)
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
