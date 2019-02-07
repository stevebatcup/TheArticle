class AddUsernameFieldsToEmailAliasLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :email_alias_logs, :old_username, :string, after: :reason
    add_column :email_alias_logs, :new_username, :string, after: :old_username
  end
end
