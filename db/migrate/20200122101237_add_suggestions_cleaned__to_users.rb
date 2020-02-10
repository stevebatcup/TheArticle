class AddSuggestionsCleanedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :suggestions_cleaned, :boolean, default: false
  end
end
