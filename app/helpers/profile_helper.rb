module ProfileHelper
	def bio_max_length
		User.bio_max_length
	end

	def bio_excerpt(user, cutoff)
		if user.bio
			user.bio.truncate_words(cutoff)
		else
			''
		end
	end

	def suggestions_as_json_data(current_user, suggestions)
		items = []
		suggestions.each do |suggestion|
			user = suggestion.suggested
			items << {
				type: 'suggestion',
				stamp: suggestion.created_at.to_i,
				date: suggestion.created_at.strftime("%e %b"),
				id: user.id,
				reason: suggestion_reason_sentence(suggestion.reason),
				isFollowingMe: current_user.is_followed_by(user),
				user: {
					displayName: user.display_name,
					username: user.username,
					image: user.profile_photo.url(:square),
					path: profile_path(slug: user.slug),
					bio: bio_excerpt(user, browser.device.mobile? ? 18 : 28),
				}
			}
		end
		items
	end

	def suggestion_reason_sentence(reason)
		case reason
		when /^exchange_([0-9]*)$/
			exchange = Exchange.find($1)
			"Also follows exchange <a href='#{exchange_path(slug: exchange.slug)}'>#{exchange.name}</a>"
		when "popular_profile"
			"This is a popular member"
		when /popular_with_following_([0-9]*)$/
			user = User.find($1)
			"Followed by <a href='#{profile_path(slug: user.slug)}'>#{user.display_name}</a>"
		when /also_highly_rated_article_([0-9]*)$/
			article = Article.find($1)
			"Also highly rated <a href='#{article_path(article)}'>#{article.title}</a>"
		end
	end

	def generate_shared_followers_sentence(current_user, user)
		members = []
		sentence = ""
		current_user.followings.each do |following|
			followee = following.followed
			members << followee if followee.followings.map(&:followed_id).include?(user.id)
		end

	  if members.any?
	  	if members.length == 1 || browser.device.mobile?
	  		sentence << "<div class='single'>
	  									<img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' />
	  								</div>
  									<p>Followed by <b>#{members[0].display_name}</b></p>"
	  	elsif members.length == 2
	  		sentence << "<div class='double'>
		  									<img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' />
			  								<img src='#{members[1].profile_photo.url(:square)}'' class='rounded-circle under' />
			  							</div>
		  								<p>Followed by <b>#{members[0].display_name}</b> and <b>#{members[1].display_name}</b></p>"
	  	else
	  		other_count = members.size - 2
	  		sentence << "<div class='double'>
		  									<img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' />
			  								<img src='#{members[1].profile_photo.url(:square)}'' class='rounded-circle under' />
			  							</div>
			  							<p>Followed by <b>#{members[0].display_name}</b>, <b>#{members[1].display_name}</b> and #{other_count} #{pluralize_without_count(other_count, 'other')} you know</p>"
			end
		end

		sentence
	end
end