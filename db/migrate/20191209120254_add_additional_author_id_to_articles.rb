class AddAdditionalAuthorIdToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :additional_author_id, :integer, default: nil, after: :author_id
  end
end
