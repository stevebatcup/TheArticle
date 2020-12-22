require "administrate/base_dashboard"

class ExchangeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    name: Field::String,
    article_count: UrlField.with_options({
      target: "_self",
      href: "/admin/articles?exchange=",
      append_id: true
    }),
    follower_count: Field::Number,
    image: ImageField,
    description: Field::Text
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :article_count,
    :follower_count
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :description,
    :article_count,
    :follower_count
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
  ].freeze

  # Overwrite this method to customize how exchanges are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(exchange)
  #   "Exchange ##{exchange.id}"
  # end
end
