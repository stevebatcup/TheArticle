class WatchListUser < ApplicationRecord
	belongs_to	:user
	belongs_to	:admin_user, class_name: 'User', foreign_key: :added_by_admin_user_id, optional: true
	enum status: [:pending, :in_review, :deleted]
	enum reason: [:added_by_admin, :quarantined_post_rejections, :concern_reports, :location]

	CONCERN_REPORT_CUTOFF = 2
	REJECTED_POST_CUTOFF = 5

	def admin_user_name
		self.admin_user.nil? ? 'Automatic' : self.admin_user.display_name
	end

	def humanised_reason
		if self.reason.to_sym == :concern_reports
			"More than #{CONCERN_REPORT_CUTOFF} concern reports"
		elsif self.reason.to_sym == :quarantined_post_rejections
			"More than #{REJECTED_POST_CUTOFF} rejected third-party posts"
		else
			self.reason.humanize
		end
	end
end