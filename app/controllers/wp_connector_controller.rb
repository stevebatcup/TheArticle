class WpConnectorController < ApplicationController
  include WpWebhookEndpoint
  skip_before_action :verify_authenticity_token

  def model_save
    model = params[:model].classify.constantize
    render_json_200_or_404 model.schedule_create_or_update(wp_id_from_params)
  end

  def model_delete
    model = params[:model].classify.constantize
    render_json_200_or_404 model.purge(wp_id_from_params)
  end
end