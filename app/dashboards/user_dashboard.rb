require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number.with_options(searchable: false),
    first_name: Field::String,
    last_name: Field::String,
    full_name: Field::String.with_options(searchable: false),
    username: Field::String,
    created_at: Field::DateTime,
    human_created_at: Field::String.with_options(searchable: false),
    subscriptions: Field::HasMany.with_options(searchable: false),
    author_id: AuthorSelectField.with_options(
      choices: Author.contributors.order(:display_name)
    ),
    exchanges: Field::HasMany.with_options(searchable: false),
    followings: Field::HasMany.with_options(class_name: "Follow", searchable: false),
    fandoms: Field::HasMany.with_options(class_name: "Follow", searchable: false),
    followers: Field::HasMany.with_options(class_name: "User", searchable: false),
    profile_suggestions: Field::HasMany.with_options(searchable: false),
    shares: Field::HasMany.with_options(searchable: false),
    search_logs: Field::HasMany.with_options(searchable: false),
    comments: Field::HasMany.with_options(searchable: false),
    opinions: Field::HasMany.with_options(searchable: false),
    feeds: Field::HasMany.with_options(searchable: false),
    notifications: Field::HasMany.with_options(searchable: false),
    concern_reports: Field::HasMany.with_options(searchable: false),
    mutes: Field::HasMany.with_options(searchable: false),
    blocks: Field::HasMany.with_options(searchable: false),
    notification_settings: Field::HasMany.with_options(searchable: false),
    communication_preferences: Field::HasMany.with_options(searchable: false),
    email_alias_logs: Field::HasMany.with_options(searchable: false),
    title: Field::String.with_options(searchable: false),
    slug: Field::String.with_options(searchable: false),
    has_completed_wizard: Field::Boolean.with_options(searchable: false),
    username: Field::String,
    display_name: Field::String,
    location: Field::String.with_options(searchable: false),
    lat: Field::String.with_options(searchable: false),
    lng: Field::String.with_options(searchable: false),
    country_code: Field::String.with_options(searchable: false),
    profile_photo: Field::String.with_options(searchable: false),
    default_profile_photo_id: Field::Number.with_options(searchable: false),
    cover_photo: Field::String.with_options(searchable: false),
    bio: Field::Text.with_options(searchable: false),
    email: Field::String,
    encrypted_password: Field::String.with_options(searchable: false),
    reset_password_token: Field::String.with_options(searchable: false),
    reset_password_sent_at: Field::DateTime.with_options(searchable: false),
    remember_created_at: Field::DateTime.with_options(searchable: false),
    sign_in_count: Field::Number.with_options(searchable: false),
    current_sign_in_at: Field::DateTime.with_options(searchable: false),
    last_sign_in_at: Field::DateTime.with_options(searchable: false),
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    confirmation_token: Field::String.with_options(searchable: false),
    confirmed_at: Field::DateTime.with_options(searchable: false),
    confirmation_sent_at: Field::DateTime.with_options(searchable: false),
    unconfirmed_email: Field::String.with_options(searchable: false),
    updated_at: Field::DateTime.with_options(searchable: false),
    signup_ip_address: Field::String.with_options(searchable: false),
    signup_ip_city: Field::String.with_options(searchable: false),
    signup_ip_region: Field::String.with_options(searchable: false),
    signup_ip_country: Field::String.with_options(searchable: false),
    notification_counter_cache: Field::Number.with_options(searchable: false),
    admin_account_status: Field::String.with_options(searchable: false),
    admin_profile_status: Field::String.with_options(searchable: false),
    age_bracket: Field::String,
    gender: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :full_name,
    :display_name,
    :username,
    :email,
    :human_created_at,
    :admin_account_status,
    :admin_profile_status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :first_name,
    :last_name,
    :display_name,
    :username,
    :email,
    :gender,
    :age_bracket,
    :location,
    :bio,
    :admin_account_status,
    :has_completed_wizard,
    :signup_ip_address,
    :signup_ip_country
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
    # :admin_account_status,
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
