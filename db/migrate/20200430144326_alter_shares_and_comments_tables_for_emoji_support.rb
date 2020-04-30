class AlterSharesAndCommentsTablesForEmojiSupport < ActiveRecord::Migration[5.2]
  def change
		execute "ALTER TABLE shares CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
		execute "ALTER TABLE shares CHANGE post post LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"

		execute "ALTER TABLE comments CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
		execute "ALTER TABLE comments CHANGE body body LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  end
end
