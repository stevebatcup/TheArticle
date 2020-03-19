class LandingPagesController < ApplicationController
	def index
		respond_to do |format|
			format.json do
				@landing_pages = LandingPage.where(status: :live).order(created_at: :asc)
			end
		end
	end

	def show
		@landing_page = nil
		mode = params[:preview].present? ? :preview : :live
		if mode == :preview
			@landing_page = LandingPage.find_by(id: params[:id])
		else
			@landing_page = LandingPage.find_by(id: params[:id], status: :live)
		end

		raise Exception.new("That landing page is not available in #{mode.to_s} mode.") if @landing_page.nil?
	end
end