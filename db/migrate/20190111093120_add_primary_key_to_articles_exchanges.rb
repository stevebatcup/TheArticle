class AddPrimaryKeyToArticlesExchanges < ActiveRecord::Migration[5.2]
  def change
  	add_column :articles_exchanges, :id, :primary_key
  end
end
