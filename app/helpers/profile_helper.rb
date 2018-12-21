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
end