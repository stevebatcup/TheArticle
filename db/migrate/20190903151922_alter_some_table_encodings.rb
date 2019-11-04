class AlterSomeTableEncodings < ActiveRecord::Migration[5.2]
  def change
  	execute "ALTER TABLE notifications CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  	execute "ALTER TABLE notifications CHANGE body body LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"

  	execute "ALTER TABLE api_logs CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  	execute "ALTER TABLE api_logs CHANGE request_data request_data LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  end
end
