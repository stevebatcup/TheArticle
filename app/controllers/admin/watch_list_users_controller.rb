module Admin
  class WatchListUsersController < Admin::ApplicationController
    before_action :authenticate_super_admin

    def valid_action?(name, resource = resource_class)
     %w[edit new destroy].exclude?(name.to_s) && super
    end

    def remove
    	if watch_list_user = WatchListUser.find(params[:id])
    		watch_list_user.destroy
    		render json: { status: :success }
    	else
    	  render json: { status: :error, message: "Watchlist item not found" }
    	end
    end

    def delete_account
    	if watch_list_user = WatchListUser.find(params[:id])
    		watch_list_user.user.delete_account("Admin deleted from watchlist", true)
    		watch_list_user.destroy
    		render json: { status: :success }
    	else
    	  render json: { status: :error, message: "Watchlist item not found" }
    	end
    end
  end
end
