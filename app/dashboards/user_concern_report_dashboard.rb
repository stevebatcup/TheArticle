require "administrate/base_dashboard"

class UserConcernReportDashboard < ConcernReportDashboard
  # Overwrite this method to customize how user concern reports are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user_concern_report)
  #   "UserConcernReport ##{user_concern_report.id}"
  # end
end
