class CreateProfileSuggestionArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_suggestion_archives do |t|
      t.integer :user_id
      t.integer :suggested_id
      t.integer :reason_for_archive
      t.datetime :created_at
    end
    add_index	:profile_suggestion_archives, :user_id
    add_index	:profile_suggestion_archives, :suggested_id
    add_index	:profile_suggestion_archives, :reason_for_archive

    remove_column	:profile_suggestions, :status, :integer
  end
end
