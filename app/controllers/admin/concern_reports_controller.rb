module Admin
  class ConcernReportsController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
      %w[edit new].exclude?(name.to_s) && super
    end
  end
end
