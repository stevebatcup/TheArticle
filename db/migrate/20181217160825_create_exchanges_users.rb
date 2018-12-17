class CreateExchangesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :exchanges_users, id: false do |t|
      t.belongs_to :exchange, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
