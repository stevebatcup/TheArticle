require "administrate/base_dashboard"

class LandingPageDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    heading: Field::String,
    slug: Field::String,
    intro: Field::Text,
    keyword_tags: Field::HasMany,
    keyword_tag_list: Field::String,
    articles_heading: Field::String,
    show_home_link: Field::Boolean,
    status: Field::Enum,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :heading,
    :slug,
    :status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :heading,
    :slug,
    :intro,
    :status,
    :articles_heading,
    :keyword_tag_list,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :heading,
    :slug,
    :intro,
    :articles_heading,
    :show_home_link,
    :status,
    :keyword_tags
  ].freeze

  # Overwrite this method to customize how landing pages are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(landing_page)
    landing_page.heading
  end
end
