require "administrate/base_dashboard"

class BlackListUserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    id: Field::Number,
    reason: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    admin_user_name: Field::String
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :id,
    :created_at,
    :admin_user_name
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :id,
    :reason,
    :created_at,
    :updated_at,
    :admin_user_name
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :reason,
  ].freeze

  # Overwrite this method to customize how black list users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(black_list_user)
    "Blacklisted user #{black_list_user.user.username}"
  end
end
