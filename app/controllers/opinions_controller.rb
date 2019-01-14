class OpinionsController < ApplicationController
	def index
		@share = Share.find(params[:share_id])
	end

	def create
		share = Share.find(params[:opinion][:share_id])
		case params[:opinion][:action]
			when 'agree'
				current_user.agree_with_post(share)
			when 'unagree'
				current_user.unagree_with_post(share)
			when 'disagree'
				current_user.disagree_with_post(share)
			when 'undisagree'
				current_user.undisagree_with_post(share)
		end

		@status = :success
		@user = current_user
	end

	def show
		@opinion = Opinion.find(params[:id])
	end
end
