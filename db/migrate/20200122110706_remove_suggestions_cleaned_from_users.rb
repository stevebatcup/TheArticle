class RemoveSuggestionsCleanedFromUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column	:users, :suggestions_cleaned, :boolean, default: false
  end
end
