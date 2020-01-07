require "administrate/base_dashboard"

class KeywordTagDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    articles: Field::HasMany,
    landing_pages: Field::HasMany,
    id: Field::Number,
    wp_id: Field::Number,
    name: Field::String,
    slug: Field::String,
    description: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    article_count: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :articles,
    :landing_pages,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :articles,
    :landing_pages,
    :id,
    :wp_id,
    :name,
    :slug,
    :description,
    :created_at,
    :updated_at,
    :article_count,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :articles,
    :landing_pages,
    :wp_id,
    :name,
    :slug,
    :description,
    :article_count,
  ].freeze

  # Overwrite this method to customize how keyword tags are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(keyword_tag)
    keyword_tag.name
  end
end
