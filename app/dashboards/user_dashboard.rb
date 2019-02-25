require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    first_name: Field::String,
    last_name: Field::String,
    created_at: Field::DateTime,
    human_created_at: Field::DateTime,
    subscriptions: Field::HasMany,
    author_id: AuthorSelectField.with_options(
      choices: Author.contributors.order(:display_name)
    ),
    exchanges: Field::HasMany,
    followings: Field::HasMany.with_options(class_name: "Follow"),
    fandoms: Field::HasMany.with_options(class_name: "Follow"),
    followers: Field::HasMany.with_options(class_name: "User"),
    profile_suggestions: Field::HasMany,
    shares: Field::HasMany,
    search_logs: Field::HasMany,
    comments: Field::HasMany,
    opinions: Field::HasMany,
    feeds: Field::HasMany,
    notifications: Field::HasMany,
    concern_reports: Field::HasMany,
    mutes: Field::HasMany,
    blocks: Field::HasMany,
    notification_settings: Field::HasMany,
    communication_preferences: Field::HasMany,
    email_alias_logs: Field::HasMany,
    status: Field::String.with_options(searchable: false),
    status_for_admin: Field::String.with_options(searchable: false),
    title: Field::String,
    slug: Field::String,
    has_completed_wizard: Field::Boolean,
    username: Field::String,
    display_name: Field::String,
    location: Field::String,
    lat: Field::String.with_options(searchable: false),
    lng: Field::String.with_options(searchable: false),
    country_code: Field::String,
    profile_photo: Field::String,
    default_profile_photo_id: Field::Number,
    cover_photo: Field::String,
    bio: Field::Text,
    email: Field::String,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String,
    last_sign_in_ip: Field::String,
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    unconfirmed_email: Field::String,
    updated_at: Field::DateTime,
    signup_ip_address: Field::String,
    signup_ip_city: Field::String,
    signup_ip_region: Field::String,
    signup_ip_country: Field::String,
    notification_counter_cache: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :human_created_at,
    :first_name,
    :last_name,
    :display_name,
    :email,
    :status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :title,
    :first_name,
    :last_name,
    :display_name,
    :username,
    :email,
    :status,
    :has_completed_wizard,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    # :subscriptions,
    # :exchanges,
    # :followings,
    # :fandoms,
    # :followers,
    # :profile_suggestions,
    # :shares,
    # :search_logs,
    # :comments,
    # :opinions,
    # :feeds,
    # :notifications,
    # :concern_reports,
    # :mutes,
    # :blocks,
    # :notification_settings,
    # :communication_preferences,
    # :email_alias_logs,
    :status,
    :title,
    :first_name,
    :last_name,
    :username,
    :display_name,
    :bio,
    :email,
    :location,
    :profile_photo,
    :default_profile_photo_id,
    :cover_photo,
    :signup_ip_address,
    :signup_ip_city,
    :signup_ip_region,
    :signup_ip_country,
    :author_id
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    user.display_name
  end
end
