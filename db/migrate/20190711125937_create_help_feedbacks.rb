class CreateHelpFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :help_feedbacks do |t|
      t.integer :question_id
      t.string :outcome
      t.integer :user_id

      t.timestamps
    end
  end
end
