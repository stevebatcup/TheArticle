class ChangeArticleContentFields < ActiveRecord::Migration[5.2]
  def change
  	change_column :articles, :content, :text, :limit => 4294967295

  	execute "ALTER TABLE articles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  	execute "ALTER TABLE articles CHANGE content content LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci"
  end
end
