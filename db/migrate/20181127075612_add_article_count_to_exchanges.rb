class AddArticleCountToExchanges < ActiveRecord::Migration[5.2]
  def change
    add_column :exchanges, :article_count, :integer, before: :is_trending, :default => 0

    Exchange.reset_column_information
    Exchange.all.each do |e|
      Exchange.update_counters e.id, :article_count => e.articles.length
    end
  end
end
