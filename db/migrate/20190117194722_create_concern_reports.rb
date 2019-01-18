class CreateConcernReports < ActiveRecord::Migration[5.2]
  def change
    create_table :concern_reports do |t|
      t.integer :reporter_id, references: :user
      t.integer :reported_id, references: :user
      t.string :primary_reason
      t.string :secondary_reason
      t.text :more_info
      t.integer :sourceable_id
      t.string :sourceable_type

      t.timestamps
    end

    add_index :concern_reports, [:sourceable_type, :sourceable_id]
    add_index :concern_reports, :reporter_id
    add_index :concern_reports, :reported_id
  end
end
