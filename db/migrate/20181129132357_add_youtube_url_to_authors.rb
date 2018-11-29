class AddYoutubeUrlToAuthors < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :youtube_url, :string
  end
end
