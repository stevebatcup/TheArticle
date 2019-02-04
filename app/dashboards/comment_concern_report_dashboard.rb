require "administrate/base_dashboard"

class CommentConcernReportDashboard < ConcernReportDashboard

  # Overwrite this method to customize how comment concern reports are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(comment_concern_report)
  #   "CommentConcernReport ##{comment_concern_report.id}"
  # end
end
