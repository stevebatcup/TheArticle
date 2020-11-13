module Admin
  class DonationsController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
		  %w[edit new destroy show].exclude?(name.to_s) && super
    end
  end
end
