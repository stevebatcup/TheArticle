class ChangeAuthorImage < ActiveRecord::Migration[5.2]
  def change
  	# drop_table	:author_images
  	add_column	:authors, :image_url, :string, after: :email
  end
end
