class AddDateToCategorisation < ActiveRecord::Migration[5.2]
  def change
  	add_column	:articles_exchanges, :created_at, :datetime
  end
end
