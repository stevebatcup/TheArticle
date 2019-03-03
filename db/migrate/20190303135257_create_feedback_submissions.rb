class CreateFeedbackSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :feedback_submissions do |t|
      t.string :name
      t.text :url
      t.string :platform
      t.string :browser
      t.string :device
      t.text :comments

      t.timestamps
    end
  end
end
