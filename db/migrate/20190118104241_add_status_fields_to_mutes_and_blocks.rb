class AddStatusFieldsToMutesAndBlocks < ActiveRecord::Migration[5.2]
  def change
  	add_column	:mutes, :status, :string, after: :muted_id
  	add_column	:blocks, :status, :string, after: :blocked_id
  end
end
