class WpConnectorController < ApplicationController
  include WpWebhookEndpoint
  skip_before_action :verify_authenticity_token

  def model_save
    model = params[:model].classify.constantize
    if ['post', 'article'].include?(params[:model].downcase)
      render_json_200_or_404 model.schedule_create_or_update(wp_id_from_params, Time.parse("#{params[:publish_date]} #{Time.zone}"))
    else
      render_json_200_or_404 model.schedule_create_or_update(wp_id_from_params)
    end
  end

  def model_delete
    model = params[:model].classify.constantize
    render_json_200_or_404 model.purge(wp_id_from_params)
  end
end