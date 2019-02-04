class AddStatusToConcernReports < ActiveRecord::Migration[5.2]
  def change
    add_column :concern_reports, :status, :integer, after: :reported_id, default: 0
  end
end
