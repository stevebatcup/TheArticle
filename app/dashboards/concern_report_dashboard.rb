require "administrate/base_dashboard"

class ConcernReportDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    reporter: Field::BelongsTo.with_options(class_name: "User"),
    reported: Field::BelongsTo.with_options(class_name: "User"),
    sourceable: Field::Polymorphic,
    id: Field::Number,
    reporter_id: Field::Number,
    reported_id: Field::Number,
    primary_reason: Field::String,
    secondary_reason: Field::String,
    more_info: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :reporter,
    :reported
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :reported,
    :reporter,
    :more_info,
    :created_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :reporter,
    :reported,
    :sourceable,
    :reporter_id,
    :reported_id,
    :primary_reason,
    :secondary_reason,
    :more_info,
  ].freeze

  # Overwrite this method to customize how concern reports are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(concern_report)
  #   "ConcernReport ##{concern_report.id}"
  # end
end
