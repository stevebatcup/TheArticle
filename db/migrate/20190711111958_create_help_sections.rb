class CreateHelpSections < ActiveRecord::Migration[5.2]
  def change
    create_table :help_sections do |t|
      t.string :title
      t.integer :sort
    end
  end
end
