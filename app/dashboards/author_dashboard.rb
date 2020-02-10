require "administrate/base_dashboard"

class AuthorDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    articles: Field::HasMany,
    author_role: Field::BelongsTo,
    user: Field::BelongsTo,
    id: Field::Number,
    wp_id: Field::Number,
    display_name: Field::Select,
    role_id: Field::String,
    email: Field::String,
    first_name: Field::String,
    last_name: Field::String,
    slug: Field::String,
    image: Field::String,
    wp_image_id: Field::Number,
    url: Field::String,
    title: Field::String,
    blurb: Field::Text,
    twitter_handle: Field::String,
    facebook_url: Field::String,
    instagram_username: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    article_count: Field::Number,
    youtube_url: Field::String,
    on_mailchimp_list: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :display_name,
    :email,
    :articles,
    :on_mailchimp_list
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :display_name,
    :author_role,
    :email,
    :first_name,
    :last_name,
    :url,
    :title,
    :blurb,
    :twitter_handle,
    :facebook_url,
    :instagram_username,
    :youtube_url,
    :on_mailchimp_list,
    :articles,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :slug,
    :on_mailchimp_list
  ].freeze

  # Overwrite this method to customize how authors are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(author)
    author.display_name
  end
end
