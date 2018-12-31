class AddExtraLocationFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column	:users, :lat, :decimal, precision: 10, scale: 7, after: :location
  	add_column	:users, :lng, :decimal, precision: 10, scale: 7, after: :lat
  	add_column	:users, :country_code, :string, after: :lng
  end
end
