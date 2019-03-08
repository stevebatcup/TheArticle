class AlterQuarantinedPostsFields < ActiveRecord::Migration[5.2]
  def change
  	execute "ALTER TABLE quarantined_third_party_shares CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  	execute "ALTER TABLE quarantined_third_party_shares CHANGE snippet snippet LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  end
end
