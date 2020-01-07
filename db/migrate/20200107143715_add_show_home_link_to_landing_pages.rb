class AddShowHomeLinkToLandingPages < ActiveRecord::Migration[5.2]
  def change
    add_column :landing_pages, :show_home_link, :boolean, after: :articles_heading, default: false
  end
end
