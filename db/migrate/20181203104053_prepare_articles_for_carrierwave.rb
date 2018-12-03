class PrepareArticlesForCarrierwave < ActiveRecord::Migration[5.2]
  def change
  	add_column	:articles, :image, :string, after: :content
  	drop_table	:featured_images
  end
end
