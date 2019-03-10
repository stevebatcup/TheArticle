class UserSharesController < ApplicationController
	before_action :authenticate_user!, except: [:index]

	def index
		respond_to do |format|
			format.json do
				page = (params[:page] || 1).to_i
				per_page = (params[:per_page] || 6).to_i
				if params[:id]
					@user = User.find(params[:id])
				else
					@user = current_user
				end
				if page == 1
					@total = @user.share_onlys.size
				end
				@shares = @user.share_onlys.page(page).per(per_page).order(created_at: :desc)
			end
		end
	end

	def opinionators
		@opinionators = []
		if user_feed_item = FeedUser.find_by(user_id: current_user.id, action_type: 'opinion', source_id: params[:share_id])
			user_feed_item.feeds.each do |feed|
				if opinion = feed.actionable
					if opinion.decision == params[:decision]
						opinionator = feed.user
						@opinionators <<  {
							displayName: opinionator.display_name,
							username: opinionator.username,
							image: opinionator.profile_photo.url(:square),
							decision: opinion.decision.capitalize
						}
					end
				end
			end
			render json: { opinionators: @opinionators }
		end
	end

	def commenters
		@commenters = []
		user_ids = []
		if user_feed_item = FeedUser.find_by(user_id: current_user.id, action_type: 'comment', source_id: params[:share_id])
			user_feed_item.feeds.each do |feed|
				if comment = feed.actionable
					commenter = feed.user
					unless user_ids.include?(commenter.id)
						@commenters <<  {
							displayName: commenter.display_name,
							username: commenter.username,
							image: commenter.profile_photo.url(:square),
						}
						user_ids << commenter.id
					end
				end
			end
			render json: { commenters: @commenters }
		end
	end

end