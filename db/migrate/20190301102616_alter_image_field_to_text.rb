class AlterImageFieldToText < ActiveRecord::Migration[5.2]
	def change
    reversible do |dir|
      change_table :articles do |t|
        dir.up   { t.change :remote_article_image_url, :text }
        dir.down { t.change :remote_article_image_url, :string }
      end
    end
  end
end
