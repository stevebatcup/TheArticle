module Admin
  class ApprovedThirdPartySharesController < Admin::ApplicationController
  	 def valid_action?(name, resource = resource_class)
  	   %w[edit new destroy].exclude?(name.to_s) && super
  	 end

  	def scoped_resource
  	  ApprovedThirdPartyShare.approved.page(params[:page]).per(10)
  	end
  end
end
