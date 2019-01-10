class EmojiSuport < ActiveRecord::Migration[5.2]
  def change
    execute "ALTER TABLE comments CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE comments CHANGE body body TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE shares CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE shares CHANGE post post TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
