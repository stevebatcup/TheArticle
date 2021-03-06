require "administrate/base_dashboard"

class QuarantinedThirdPartyShareDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    article: Field::BelongsTo,
    id: Field::Number,
    url: UrlField,
    status: Field::String.with_options(searchable: false),
    heading: Field::String,
    snippet: Field::Text,
    post: Field::Text,
    image: ImageField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :heading,
    :post
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :heading,
    :snippet,
    :image,
    :post,
    :url,
    :created_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
  ].freeze

  # Overwrite this method to customize how quarantined third party shares are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(quarantined_third_party_share)
  #   "QuarantinedThirdPartyShare ##{quarantined_third_party_share.id}"
  # end
end
