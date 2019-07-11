class CreateHelpContents < ActiveRecord::Migration[5.2]
  def change
    create_table :help_contents do |t|
      t.integer :section_id
      t.text :question
      t.text :answer
      t.integer :sort
      t.integer :top_question_sort, default: nil
    end
  end
end
