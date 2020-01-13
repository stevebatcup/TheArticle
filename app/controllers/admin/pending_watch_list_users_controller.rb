module Admin
  class PendingWatchListUsersController < WatchListUsersController
  	def send_to_review
  		if watch_list_user = WatchListUser.find(params[:id])
  			watch_list_user.update_attribute(:status, :in_review)
  			render json: { status: :success }
  		else
  		  render json: { status: :error, message: "Watchlist item not found" }
  		end
  	end
  end
end
