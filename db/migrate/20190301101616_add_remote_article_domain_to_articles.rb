class AddRemoteArticleDomainToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :remote_article_domain, :string, after: :remote_article_url
  end
end
