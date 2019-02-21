class CreateFeedsNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds_notifications, id: false do |t|
    	t.belongs_to :feed, index: true, foreign_key: true
    	t.belongs_to :notification, index: true, foreign_key: true
    end
  end
end
