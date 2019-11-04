class AddMetaExtrasToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :meta_keywords, :text
    add_column :articles, :meta_entities, :text
    add_column :articles, :meta_concepts, :text
    add_column :articles, :has_bibblio_meta, :boolean, default: false

    add_index :articles, :meta_keywords, type: :fulltext
    add_index :articles, :meta_entities, type: :fulltext
    add_index :articles, :meta_concepts, type: :fulltext
  end
end
