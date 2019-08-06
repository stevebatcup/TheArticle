require "administrate/base_dashboard"

class EmailLogDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    service: Field::String,
    user_id: Field::Number,
    user: Field::BelongsTo,
    subject: Field::String,
    content: Field::String,
    request_type: Field::String,
    request_method: Field::String,
    request_data: Field::Text,
    response: Field::Text,
    status: Field::Text,
    created_at: Field::DateTime,
    admin_date: Field::String
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :subject,
    :status,
    :admin_date
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :admin_date,
    :subject,
    :content,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [].freeze

  # Overwrite this method to customize how email logs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(email_log)
  #   "EmailLog ##{email_log.id}"
  # end
end
