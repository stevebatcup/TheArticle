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

	def following_summary(recent_followings, direction="following")
		if recent_followings.any?
		  name_limit = 3
		  sentence = direction == "following" ? " followed " : " was followed by "
		  names = []
		  stamp = recent_followings.first.created_at.to_i
		  date = recent_followings.first.created_at.strftime("%e %b")
		  recent_followings.each_with_index do |rf, index|
		  	if direction == "following"
			    profile = rf.followed
			  else
			  	profile = rf.user
			  end
		  	names << link_to(profile.display_name, profile_path(slug: profile.slug))
		    break if index >= (name_limit - 1)
		  end
		  if names.any?
			  if recent_followings.length > name_limit
			    offset = recent_followings.length - name_limit
			    sentence << "#{names.join(", ")} and #{pluralize(offset, 'other')}"
			  else
			  	if names.length == 1
			  		sentence << names[0]
			  	else
			  		sentence << names.slice(0, names.length - 1).join(", ") + " and #{names.last}"
					end
			  end
			end
		  {
		  	sentence: sentence,
		  	stamp: stamp,
		  	date: date
		  }
		else
			{}
		end
	end
end