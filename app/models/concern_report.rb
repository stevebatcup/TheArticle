class ConcernReport < ApplicationRecord
	belongs_to	:reporter, class_name: 'User'
	belongs_to	:reported, class_name: 'User'
	belongs_to	:sourceable, polymorphic: true
	after_create	:send_admin_email
	enum	status: [:pending, :seen]

	def send_admin_email
		if (self.secondary_reason.present?) || (self.more_info.length > 0)
			AdminMailer.concern_report(self).deliver_now
		end
	end

	def sourceable_type_for_email
		case self.sourceable_type
		when 'Comment'
			'comment'
		when 'Share'
			'post'
		when 'User'
			'Profile'
		end
	end

	def build_reason_sentence
		reasons = []
		case self.primary_reason
		# PROFILES
		when 'not_interested_account'
			reasons << "I'm not interested in this account"

		when 'dont_agree_views'
			reasons << "I do not agree with this user's views"

		when 'suspicious_or_spam_account'
			reasons << "It's suspicious or spam"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'fake_account'
					reasons << "It's a fake account"
				when 'harmful_site_link'
					reasons << "It's sharing links to potentially harmful, malicious or phishing sites"
				when 'posting_spam'
					reasons << "It's posting spam"
				when 'suspicious_something_else'
					reasons << "It's something else"
				end
			end

		when 'pretending'
			reasons << "They're pretending to be me or someone else"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'me'
					reasons << "Me"
				when 'someone_represent'
					reasons << "Someone I represent"
				when 'pretending_someone_else'
					reasons << "Someone else"
				end
			end

		when 'offensive'
			reasons << "Their posts are offensive or abusive"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'disrespectful'
					reasons << "They are disrespectful or offensive"
				when 'harassment_or_threats'
					reasons << "They include targeted harassment or threats"
				when 'category_hate'
					reasons << "They direct hate against a protected category (e.g. race, religion, gender, orientation, disability)"
				when 'threat_of_violence'
					reasons << "They threaten violence or physical harm"
				when 'offensive_something_else'
					reasons << "It's something else"
				end
			end

		when 'hacked'
			reasons << "It appears their account is hacked"

		when 'offensive_content'
			reasons << "Their profile info includes offensive or abusive content"

		when 'offensive_photo'
			reasons << "Their profile photos include offensive or abusive content"

		when 'something_else_account'
			reasons << "I want to report something else"

		# POSTS
		when 'not_interested_post'
			reasons << "I'm not interested in this post"

		when 'dont_agree_post'
			reasons << "I do not agree with this post"

		when 'suspicious_or_spam_post'
			reasons << "It's suspicious or spam"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'fake_account'
					reasons << "It's from a fake account"
				when 'harmful_site_link'
					reasons << "It's sharing links to potentially harmful, malicious or phishing sites"
				when 'posting_spam'
					reasons << "It's posting spam"
				when 'suspicious_something_else'
					reasons << "It's something else"
				end
			end

		when 'abusive'
			reasons << "It's abusive or harmful"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'disrespectful'
					reasons << "It's disrespectful or offensive"
				when 'harassment_or_threats'
					reasons << "It includes targeted harassment or threats"
				when 'category_hate'
					reasons << "It directs hate against a protected category (e.g. race, religion, gender, orientation, disability)"
				when 'threat_of_violence'
					reasons << "It threatens violence or physical harm"
				when 'offensive_something_else'
					reasons << "It's something else"
				end
			end

		when 'something_else_post'
			reasons << "I want to report something else"

		# COMMENTS
		when 'suspicious_or_spam_comment'
			reasons << "It's suspicious or spam"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'fake_account'
					reasons << "It's from a fake account"
				when 'harmful_site_link'
					reasons << "It's sharing links to potentially harmful, malicious or phishing sites"
				when 'posting_spam'
					reasons << "It's posting spam"
				when 'suspicious_something_else'
					reasons << "It's something else"
				end
			end

		when 'abusive_comment'
			reasons << "It's abusive or harmful"
			unless self.secondary_reason.nil?
				case self.secondary_reason
				when 'disrespectful'
					reasons << "It's disrespectful or offensive"
				when 'harassment_or_threats'
					reasons << "It includes targeted harassment or threats"
				when 'category_hate'
					reasons << "It directs hate against a protected category (e.g. race, religion, gender, orientation, disability)"
				when 'threat_of_violence'
					reasons << "It threatens violence or physical harm"
				when 'offensive_something_else'
					reasons << "It's something else"
				end
			end

			when 'something_else_comments'
				reasons << "I want to report something else"
		end
		reasons.join(" AND ")
	end

	def admin_path
		case self.sourceable_type
		when 'Comment'
			"/admin/comment_concern_reports/#{self.id}"
		when 'Share'
			"/admin/share_concern_reports/#{self.id}"
		when 'User'
			"/admin/user_concern_reports/#{self.id}"
		end
	end

end
