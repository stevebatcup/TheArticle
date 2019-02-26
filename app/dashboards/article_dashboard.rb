require "administrate/base_dashboard"

class ArticleDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    keyword_tags: Field::HasMany,
    author: Field::BelongsTo,
    shares: Field::HasMany,
    categorisations: Field::HasMany,
    exchanges: Field::HasMany,
    id: Field::Number,
    wp_id: Field::Number,
    title: Field::String,
    content: Field::Text,
    image: Field::String,
    image_caption: Field::String,
    wp_image_id: Field::Number,
    slug: Field::String,
    remote_article_url: Field::String,
    remote_article_image_url: Field::String,
    excerpt: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    published_at: Field::DateTime,
    canonical_url: Field::String,
    page_title: Field::Text,
    meta_description: Field::Text,
    social_image: Field::String,
    robots_nofollow: Field::Boolean,
    robots_noindex: Field::Boolean,
    is_sponsored: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :keyword_tags,
    :author,
    :shares,
    :categorisations,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :keyword_tags,
    :author,
    :shares,
    :categorisations,
    :exchanges,
    :id,
    :wp_id,
    :title,
    :content,
    :image,
    :image_caption,
    :wp_image_id,
    :slug,
    :remote_article_url,
    :remote_article_image_url,
    :excerpt,
    :created_at,
    :updated_at,
    :published_at,
    :canonical_url,
    :page_title,
    :meta_description,
    :social_image,
    :robots_nofollow,
    :robots_noindex,
    :is_sponsored,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :keyword_tags,
    :author,
    :shares,
    :categorisations,
    :exchanges,
    :wp_id,
    :title,
    :content,
    :image,
    :image_caption,
    :wp_image_id,
    :slug,
    :remote_article_url,
    :remote_article_image_url,
    :excerpt,
    :published_at,
    :canonical_url,
    :page_title,
    :meta_description,
    :social_image,
    :robots_nofollow,
    :robots_noindex,
    :is_sponsored,
  ].freeze

  # Overwrite this method to customize how articles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(article)
  #   "Article ##{article.id}"
  # end
end