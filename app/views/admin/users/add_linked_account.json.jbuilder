json.status @status
json.message @message if @message
json.id @linked_account.linked_account_id if @linked_account
json.displayName @linked_account.linked_account.display_name if @linked_account