class CreateShares < ActiveRecord::Migration[5.2]
  def change
    create_table :shares do |t|
      t.integer :user_id, index: true
      t.integer :article_id, index: true
      t.integer :rating_well_written
      t.integer :rating_valid_points
      t.integer :rating_agree
      t.text :comments

      t.timestamps
    end
  end
end
