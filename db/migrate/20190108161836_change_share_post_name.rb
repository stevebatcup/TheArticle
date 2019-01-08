class ChangeSharePostName < ActiveRecord::Migration[5.2]
  def change
  	remove_column	:shares, :comments, :text
  	add_column	:shares, :post, :text, after: :article_id
  end
end
