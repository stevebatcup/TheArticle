module Admin
  class UsersController < Admin::ApplicationController

    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, :created_at),
        params.fetch(resource_name, {}).fetch(:direction, :desc),
      )
    end

    def set_records_per_page
      respond_to do |format|
        format.json do
          cookies.permanent[:admin_user_records_per_page] = params[:per_page]
        end
      end
    end

    def records_per_page
      params[:per_page] || cookies.permanent[:admin_user_records_per_page] || 50
    end

    def add_to_blacklist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_blacklist("Blacklisted from admin")
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
            user.add_to_watchlist("Added from admin")
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

  private

    # def user_blacklist_params
    #   params.require(:user_blacklist).permit(:user_id, :reason)
    # end
  end
end
