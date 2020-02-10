class AddStatusToLandingPages < ActiveRecord::Migration[5.2]
  def change
    add_column :landing_pages, :status, :integer, default: 0, after: :show_home_link
  end
end
