class AddSeoFieldsToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :canonical_url, :string
    add_column :articles, :page_title, :text
    add_column :articles, :meta_description, :text
    add_column :articles, :social_image, :string
    add_column :articles, :robots_nofollow, :boolean
    add_column :articles, :robots_noindex, :boolean
  end
end
