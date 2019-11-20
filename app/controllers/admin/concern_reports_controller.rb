module Admin
  class ConcernReportsController < Admin::ApplicationController

    before_action :authenticate_super_admin

    def valid_action?(name, resource = resource_class)
      %w[edit new destroy].exclude?(name.to_s) && super
    end

    def update
    	report = ConcernReport.find(params[:id])
    	if report.update_attribute(:status, :seen)
    		@status = :success
    	else
    		@status = :error
    		@message = report.errors.full_messages.first
    	end
    end
  end
end
