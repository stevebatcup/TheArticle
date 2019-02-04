# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin

    rescue_from SecurityError do |exception|
      sign_out current_user if current_user
      redirect_to new_user_session_url, alert: "You must be signed in as a site administrator to access that page."
    end

    def authenticate_admin
      raise SecurityError unless current_user.try(:is_admin?)
    end

    def quarantined_post_count
      @quarantined_post_count ||= QuarantinedThirdPartyShare.where(status: :pending).size
    end
    helper_method :quarantined_post_count

    def user_concern_report_count
      @user_concern_report_count ||= UserConcernReport.all.size
    end
    helper_method :user_concern_report_count

    def comment_concern_report_count
      @comment_concern_report_count ||= CommentConcernReport.all.size
    end
    helper_method :comment_concern_report_count

    def share_concern_report_count
      @share_concern_report_count ||= ShareConcernReport.all.size
    end
    helper_method :share_concern_report_count

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end