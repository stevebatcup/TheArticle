class ProfileSuggestionsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.json do
				@from_wizard = params[:from_wizard].present?
				if params[:query]
					@search_results = User.search_for_suggestions(current_user, params[:query])
				elsif params[:use_bibblio] && current_user.on_bibblio?
					@bibblio_results = BibblioApiService::Users.new(current_user).get_suggestions(10)
					# Author suggestions
					current_user.pending_author_suggestions(10).each_with_index do |author_suggestion, index|
						insert_point = ((index+1) * 4) - 1
						if @bibblio_results[insert_point].nil?
							@bibblio_results << author_suggestion.suggested
						else
							@bibblio_results.insert(insert_point, author_suggestion.suggested)
						end
					end
					@bibblio_results = @bibblio_results.uniq
				else
					already_following_ids = current_user.followings.map(&:followed_id)
					suggestions = current_user.pending_suggestions
					ProfileSuggestionsGeneratorJob.perform_later(current_user, false, 15) if suggestions.empty?
					limit_to = 75

					# Suggestions for you
					@for_yous = suggestions.where.not("reason LIKE ?", 'popular_with_%').limit(limit_to).to_a
					@for_yous.reject! do |suggestion|
						already_following_ids.include?(suggestion.suggested_id)
					end

					# Author suggestions
					current_user.pending_author_suggestions(10).each_with_index do |author_suggestion, index|
						insert_point = ((index+1) * 4) - 1
						unless @for_yous[insert_point].nil?
							@for_yous.insert(insert_point, author_suggestion)
						end
					end

					# Popular suggestions
					unless @from_wizard
						populars_limit =  (limit_to * 2) - @for_yous.size
						@populars = suggestions.where("reason LIKE ?", 'popular_with_%').limit(populars_limit).to_a
						@populars.reject! do |suggestion|
							already_following_ids.include?(suggestion.suggested_id)
						end
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
