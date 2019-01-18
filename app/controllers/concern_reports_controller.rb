class ConcernReportsController < ApplicationController
	def create
		if concern_report_params[:via][:type] == 'comment'
			sourceable = Comment.find(concern_report_params[:via][:id])
		elsif concern_report_params[:via][:type] == 'post'
			sourceable = Share.find(concern_report_params[:via][:id])
		elsif concern_report_params[:via][:type] == 'profile'
			sourceable = User.find(concern_report_params[:via][:id])
		end
		@report = ConcernReport.new({
			reporter_id: current_user.id,
			reported_id: concern_report_params[:user_id],
			primary_reason: concern_report_params[:reason][:primary],
			secondary_reason: concern_report_params[:reason][:secondary],
			more_info: concern_report_params[:more_info],
			sourceable: sourceable
		})
		if @report.save
			@status = :success
		else
			@status = :error
		end
	end

private

	def concern_report_params
		params.require(:concern_report).permit(:user_id, :more_info, via: [:type, :id], reason: [:primary, :secondary])
	end
end