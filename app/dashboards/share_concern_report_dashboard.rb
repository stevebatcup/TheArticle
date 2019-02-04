require "administrate/base_dashboard"

class ShareConcernReportDashboard < ConcernReportDashboard
  # Overwrite this method to customize how share concern reports are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(share_concern_report)
  #   "ShareConcernReport ##{share_concern_report.id}"
  # end
end
