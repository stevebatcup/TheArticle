class CreateFeedUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :feed_users do |t|
      t.integer :user_id
      t.string :action_type
      t.integer :source_id

      t.timestamps
    end

    create_table :feed_users_feeds, id: false do |t|
    	t.belongs_to :feed_user, index: true, foreign_key: true
    	t.belongs_to :feed, index: true, foreign_key: true
    end
  end
end
