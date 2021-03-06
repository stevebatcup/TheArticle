require "administrate/base_dashboard"

class WatchListUserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: OpenAccountField,
    id: Field::Number,
    reason: Field::Number,
    humanised_reason: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    admin_user_name: Field::String,
    status: Field::String
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :humanised_reason,
    :admin_user_name,
    :created_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :humanised_reason,
    :created_at,
    :admin_user_name
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [].freeze

  # Overwrite this method to customize how watch list users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(watch_list_user)
    "Watchlisted user '#{watch_list_user.user.full_name}'"
  end
end
