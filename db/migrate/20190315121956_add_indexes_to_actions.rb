class AddIndexesToActions < ActiveRecord::Migration[5.2]
  def change
    add_index :opinions, :user_id
    add_index :opinions, :share_id
    add_index :opinions, [:user_id, :share_id, :decision]

    add_index :follows, :user_id
    add_index :follows, :followed_id

    add_index :blocks, :user_id
    add_index :blocks, :blocked_id

    add_index :mutes, :user_id
    add_index :mutes, :muted_id

  end
end
