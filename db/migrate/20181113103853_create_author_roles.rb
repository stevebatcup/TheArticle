class CreateAuthorRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :author_roles do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
