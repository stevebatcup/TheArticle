class AddIsSponsoredToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :is_sponsored, :boolean, default: false

    Article.reset_column_information
  	Article.all.each do |a|
    	Article.update_counters a.id, is_sponsored: a.author.author_role.slug == 'sponsor' ? 1 : 0
  	end
  end
end
