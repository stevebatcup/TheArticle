class AddGenderAndAgeFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :string, after: :display_name
    add_column :users, :age_bracket, :string, after: :gender
  end
end
