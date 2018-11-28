class AddArticleCountToAuthors < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :article_count, :integer

    Author.reset_column_information
  	Author.all.each do |a|
    	Author.update_counters a.id, article_count: a.articles.size
  	end
  end
end
