class AddImages < ActiveRecord::Migration[5.2]
  def change
  	create_table	:featured_images do |t|
  		t.integer :article_id
  		t.integer :wp_id
  		t.string :url

  		t.timestamps
  	end
  end
end
