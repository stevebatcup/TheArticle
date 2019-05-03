module Admin
  class ArticlesController < Admin::ApplicationController
    def valid_action?(name, resource = resource_class)
      %w[new create show].exclude?(name.to_s) && super
    end

    def show_action?(name, resource = resource_class)
      %w[new create show].exclude?(name.to_s) && super
    end

    def scoped_resource
      Article.not_remote
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
