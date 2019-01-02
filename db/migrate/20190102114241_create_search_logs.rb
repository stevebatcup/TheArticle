class CreateSearchLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :search_logs do |t|
      t.integer :user_id, index: true
      t.string :term, index: true
      t.integer :all_results_count, default: 0
      t.integer :articles_results_count, default: 0
      t.integer :contributors_results_count, default: 0
      t.integer :profiles_results_count, default: 0
      t.integer :exchanges_results_count, default: 0
      t.integer :posts_results_count, default: 0

      t.timestamps
    end
  end
end
