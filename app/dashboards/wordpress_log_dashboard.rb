require "administrate/base_dashboard"

class WordpressLogDashboard < Administrate::BaseDashboard
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
    request_type: Field::String,
    request_method: Field::String,
    request_data: Field::Text,
    response: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    admin_type: SanitizedStringField.with_options(searchable: false),
    admin_article_title: SanitizedStringField.with_options(searchable: false),
    admin_date: SanitizedStringField.with_options(searchable: false)
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :admin_type,
    :admin_article_title,
    :admin_date
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :service,
    :user_id,
    :request_type,
    :request_method,
    :request_data,
    :response,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :service,
    :user_id,
    :request_type,
    :request_method,
    :request_data,
    :response,
  ].freeze

  # Overwrite this method to customize how wordpress logs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(wordpress_log)
  #   "WordpressLog ##{wordpress_log.id}"
  # end
end
