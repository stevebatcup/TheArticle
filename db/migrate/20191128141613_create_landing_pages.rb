class CreateLandingPages < ActiveRecord::Migration[5.2]
  def change
    create_table :landing_pages do |t|
      t.string :heading
      t.string :slug
      t.text :intro
      t.string :articles_heading

      t.timestamps
    end

    create_table :keyword_tags_landing_pages, id: false do |t|
    	t.belongs_to :keyword_tag, index: true, foreign_key: true
    	t.belongs_to :landing_page, index: true, foreign_key: true
    end
  end
end
