class AddOnBibblioToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :on_bibblio, :boolean, default: false
  end
end
