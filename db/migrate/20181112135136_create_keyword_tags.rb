class CreateKeywordTags < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_tags do |t|
      t.integer :wp_id
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps null: false
    end

  	create_table :articles_keyword_tags, id: false do |t|
	    t.belongs_to :article, index: true, foreign_key: true
	    t.belongs_to :keyword_tag, index: true, foreign_key: true
	  end
  end
end
