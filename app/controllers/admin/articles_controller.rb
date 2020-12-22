module Admin
  class ArticlesController < Admin::ApplicationController
    def order
      @order ||= begin
        order_field = params.fetch(resource_name, {}).fetch(:order, :ratings_count)
        order_direction = params.fetch(resource_name, {}).fetch(:direction, :desc)

        Administrate::Order.new( order_field, order_direction )
      end
    end

    def valid_action?(name, resource = resource_class)
      %w[new create show].exclude?(name.to_s) && super
    end

    def show_action?(name, resource = resource_class)
      %w[new create show].exclude?(name.to_s) && super
    end

    def scoped_resource
      if params[:exchange].present?
        exchange = Exchange.find(params[:exchange])
        return Article.not_remote unless exchange

        Article.joins(:exchanges).where(exchanges: { id: exchange.id })
      else
        Article.not_remote
      end
    end

    def purge
      if article = Article.find_by(id: params[:id])
        article.purge_self
        @status = :success
        redirect_to "/admin/articles?page=#{params[:page]}"
      else
        @status = :error
      end
    end
  end
end
