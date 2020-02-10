class AddOnMailchimpListToAuthors < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :on_mailchimp_list, :boolean, default: false
  end
end
