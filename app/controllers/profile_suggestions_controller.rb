class ProfileSuggestionsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.json do
				@from_wizard = params[:from_wizard].present?
				if params[:query]
					@search_results = User.search_for_suggestions(current_user, params[:query])
				else
					suggestions = current_user.pending_suggestions
					current_user.generate_suggestions(false, 10) if suggestions.empty?
					already_following_ids = current_user.followings.map(&:followed_id)
					@for_yous = suggestions.where.not("reason LIKE ?", 'popular_with_%').where.not(suggested_id: already_following_ids).limit(50).to_a
					current_user.pending_author_suggestions(10).each_with_index do |author_suggestion, index|
						insert_point = ((index+1) * 4) - 1
						unless @for_yous[insert_point].nil?
							@for_yous.insert(insert_point, author_suggestion)
						end
					end
					unless @from_wizard
						populars_limit = 50 + (50- @for_yous.size)
						@populars = suggestions.where("reason LIKE ?", 'popular_with_%').where.not(suggested_id: already_following_ids).limit(populars_limit)
					end
				end
			end
			format.html do
				if !browser.device.mobile?
					@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 3)
					@trending_articles = Article.latest.limit(Author.sponsors.any? ? 8 : 9).all.to_a
					@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
					@contributors_for_spotlight = Author.contributors_for_spotlight(3)
					@recent_articles = Article.recent
					@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				end
			end
		end
	end

	def update
		if suggestion = ProfileSuggestion.find_by(user_id: current_user.id, suggested_id: params[:id])
			suggestion.ignore
			render json: { status: :success }
		else
			render json: { status: :error, message: "Cannot find suggestion" }
		end
	end
end
