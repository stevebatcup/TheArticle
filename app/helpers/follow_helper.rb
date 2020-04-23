module FollowHelper
	def follow_as_json_data(follow, current_user=nil, sentence='', source_type=nil)
		sentence = "<b>#{follow.user.display_name}</b> <span class='text-muted'>#{follow.user.username}</span> followed #{follow.followed.display_name}" if sentence.length == 0
		{
			type: 'follow',
			sourceType: source_type,
			stamp: follow.created_at.to_i,
			date: event_date_formatted(follow.created_at),
			sentence: sentence,
			follower: {
				id: follow.user.id,
				path: profile_path(slug: follow.user.slug),
				displayName: follow.user.display_name,
				username: follow.user.username,
				image: follow.user.profile_photo.url(:square)
			},
			followed: {
				id: follow.followed.id,
				displayName: (current_user && current_user == follow.followed) ? "You" : follow.followed.display_name,
				username: follow.followed.username,
				image: follow.followed.profile_photo.url(:square)
			}
		}
	end

	def following_summary(user, recent_followings, direction="following")
		if recent_followings.any?
		  name_limit = 3
		  sentence = "<b>#{user.display_name}</b> <span class='text-muted'>#{user.username}</span>"
		  sentence += (direction == "following" ? " followed " : " was followed by ")
		  names = []
		  stamp = recent_followings.first.created_at.to_i
		  date = event_date_formatted(recent_followings.first.created_at)
		  recent_followings.each_with_index do |rf, index|
		  	if direction == "following"
			    profile = rf.followed
			  else
			  	profile = rf.user
			  end
			  if profile.has_active_status? && profile.has_completed_wizard
			  	names << link_to(profile.display_name, profile_path(slug: profile.slug), class: 'text-green')
			  end
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
			  {
			  	sentence: sentence,
			  	stamp: stamp,
			  	date: date
			  }
			 else
			 	{}
			end
		else
			{}
		end
	end
end