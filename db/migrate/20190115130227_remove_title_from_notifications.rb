class RemoveTitleFromNotifications < ActiveRecord::Migration[5.2]
  def change
  	remove_column	:notifications, :title, :string
  end
end
