class CreateFutureArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :future_articles do |t|
      t.integer :wp_id
      t.datetime :publish_date

      t.timestamps
    end
  end
end
