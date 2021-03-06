class User < ApplicationRecord
  # POPULAR_FOLLOW_COUNT = 5
  # Include default devise modules. Others available are:
  # :lockable and :omniauthable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :confirmable, :trackable, :rememberable

  validates_presence_of	:first_name, :last_name, on: :create
  validate :user_cannot_be_blacklisted, on: :create

  enum  status: %i[active deactivated deleted]
  enum  admin_level: %i[nothing admin super_admin]

  has_many  :subscriptions
  has_many  :exchanges, through: :subscriptions

  before_create :assign_default_profile_photo_id
  before_create :strip_whitespace
  before_create :fix_double_names
  after_create :assign_default_settings
  after_create :start_default_notification_settings_job
  after_create :add_to_mailchimp
  after_create :delay_donation_interstitial

  before_save :downcase_username

  mount_base64_uploader :profile_photo, ProfilePhotoUploader, file_name: ->(u) { u.photo_filename(:profile) }
  mount_base64_uploader :cover_photo, CoverPhotoUploader, file_name: ->(u) { u.photo_filename(:cover) }

  # people I follow
  has_many :followings, class_name: 'Follow'

  # people who follow me
  has_many :fandoms, class_name: 'Follow', foreign_key: :followed_id
  has_many :followers, through: :fandoms, source: :user

  has_many :profile_suggestions
  has_many :profile_suggestion_archives
  has_many :shares
  has_many :search_logs
  has_many :comments
  has_many :opinions
  has_many :feeds
  has_many :notifications
  has_many :concern_reports, as: :sourceable
  has_many :all_concern_reports, class_name: 'ConcernReport', foreign_key: :reporter_id
  has_many :concerns_reported, class_name: 'ConcernReport', foreign_key: :reported_id

  has_many  :mutes
  has_many  :muted_bys, class_name: 'Mute', foreign_key: :muted_id
  has_many  :blocks
  has_many  :blocked_bys, class_name: 'Block', foreign_key: :blocked_id

  has_many  :notification_settings
  has_many  :communication_preferences

  has_many  :email_alias_logs

  has_one  :black_list_user
  has_one  :watch_list_user
  has_many  :quarantined_third_party_shares
  has_many  :feed_users

  has_many  :follow_mutes
  has_many  :exchange_mutes
  has_many  :interaction_mutes

  has_many  :additional_emails
  has_many  :linked_accounts

  has_many  :user_admin_notes
  has_many  :push_tokens

  belongs_to :author, optional: true

  include Suggestable
  include Shareable
  include Followable
  include Opinionable
  include Adminable
  include Mailable
  include Pushable

  attr_writer :login

  def self.search(query, size=50)
    where("display_name LIKE '%#{query}%' OR username LIKE '%#{query}%' OR location LIKE '%#{query}%' OR bio LIKE '%#{query}%'")
      .where(status: 'active')
      .where(has_completed_wizard: true)
      .limit(size)
  end

  def strip_whitespace
    self.first_name = first_name.strip unless first_name.nil?
    self.last_name = last_name.strip unless last_name.nil?
    self.email = email.strip unless email.nil?
  end

  def fix_double_names
    if first_name == last_name
      words = first_name.split
      if words.count > 1
        self.first_name = words[0]
        self.last_name = words.drop(1).join(' ')
      end
    end
  end

  def remember_me
    true
  end

  def downcase_username
    self.username = username.downcase
  end

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def start_default_notification_settings_job
    UserDefaultNotificationSettingsJob.set(wait_until: 10.seconds.from_now).perform_later(self)
  end

  def add_to_mailchimp
    AddUserToMailchimpJob.set(wait_until: 30.seconds.from_now).perform_later(self)
  end

  def assign_default_settings
    uname = generate_usernames.first
    self.slug = uname.downcase
    self.username = "@#{uname}"
    self.display_name = "#{first_name.strip} #{last_name.strip}"
    set_default_exchanges
    save
  end

  def set_default_exchanges
    trending_exchange_ids = Exchange.trending_list.map(&:id)
    other_exchange_ids = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc).map(&:id)
    self.exchange_ids = trending_exchange_ids.to_a.concat(other_exchange_ids)
    exchange_ids << Exchange.editor_item.id
  end

  def set_default_notification_settings
    notification_settings.build({ key: 'email_followers', value: 'as_it_happens' })
    notification_settings.build({ key: 'email_exchanges', value: 'daily' })
    notification_settings.build({ key: 'email_responses', value: 'never' })
    notification_settings.build({ key: 'email_replies', value: 'never' })
    notification_settings.build({ key: 'push_followers', value: 'no' })
    notification_settings.build({ key: 'push_exchanges', value: 'no' })

    communication_preferences.build({ preference: 'newsletters_weekly', status: true })
    communication_preferences.build({ preference: 'newsletters_offers', status: true })
    save
  end

  def self.active
    where(status: :active, has_completed_wizard: true)
  end

  def has_active_status?
    %i[active deactivated].include?(status.to_sym)
  end

  def active_for_authentication?
    has_active_status?
  end

  def inactive_message
    has_active_status? ? super : :account_deleted
  end

  def full_name
    account_name
  end

  def account_name
    "#{first_name.strip} #{last_name.strip}"
  end

  def set_ip_data(request)
    ip = request.remote_ip
    # ip = '86.150.196.99'
    self.signup_ip_address = ip
    if geo_info = Geocoder.search(ip).first
      self.signup_ip_city = geo_info.city
      self.signup_ip_region = geo_info.region
      self.signup_ip_country = geo_info.country
    end
  end

  def photo_filename(type)
    "#{type}_photo_#{id}_#{Time.now.to_i}"
  end

  def assign_default_profile_photo_id
    self.default_profile_photo_id = rand(1..75)
  end

  def default_display_name
    "#{first_name.strip} #{last_name.strip}".gsub(/[^a-z_'\- ]/i, '')
  end

  def generate_usernames(amount = 1)
    items = []
    username = ''
    i = 0
    amount.times do
      begin
        username = "#{first_name.downcase.strip}#{last_name.downcase.strip}#{i > 0 ? i : ''}"
        username = username.gsub(/[^0-9a-z_]/i, '')
        i += 1
      end while !self.class.is_username_available?("@#{username}") || items.include?(username)
      items << username
    end
    items
  end

  def complete_profile_from_wizard(params)
    self.display_name = params[:names][:display_name][:value]
    self.username = "@#{params[:names][:username][:value]}"
    self.slug = params[:names][:username][:value].downcase
    self.location = params[:location][:value]
    self.private_location = params[:location][:private_value]
    self.lat = params[:location][:lat]
    self.lng = params[:location][:lng]
    self.country_code = params[:location][:country_code]
    self.has_completed_wizard = 1
    save
  end

  def self.popular_users(excludes = [], popular_follow_count = 5, amount = 10)
    active.joins(:followers)
          .where.not(id: excludes)
          .group('users.id')
          .order('count(follows.user_id) DESC')
          .having("count(follows.user_id) >= #{popular_follow_count}")
          .limit(amount)
  end

  def self.bio_max_length
    180
  end

  def self.is_username_available?(username)
    !find_by(username: username).present?
  end

  def update_notification_counter_cache
    count = notifications.where(is_new: true).size
    update_attribute(:notification_counter_cache, count)
  end

  def has_muted(user)
    muted_id_list.include?(user.id)
  end

  def muted_list
    @muted_list ||= mutes.where(status: :active)
  end

  def muted_id_list
    @muted_id_list ||= muted_list.map(&:muted_id)
  end

  def has_blocked(user)
    blocked_id_list.include?(user.id)
  end

  def blocked_list
    @blocked_list ||= blocks.where(status: :active)
  end

  def blocked_id_list
    @blocked_id_list ||= blocked_list.map(&:blocked_id)
  end

  def is_comment_disallowed?(comment)
    if has_blocked(comment.user)
      true
    elsif comment.user.has_blocked(self)
      true
    else
      blocked_usernames = blocked_list.map(&:blocked).map(&:username)
      blocked_usernames.any? { |username| comment.body.include?(username) }
    end
  end

  def profile_is_deactivated?
    status.to_sym == :deactivated
  end

  def clear_user_data(deleting_account = false)
    followings.destroy_all
    fandoms.destroy_all
    shares.destroy_all
    comments.destroy_all
    opinions.destroy_all
    quarantined_third_party_shares.destroy_all
    ProfileSuggestion.delete_suggested(self)
    ProfileSuggestionArchive.delete_suggested(self)
    if deleting_account
      notifications.destroy_all
      feed_users.destroy_all
      feeds.destroy_all
      profile_suggestions.destroy_all
      profile_suggestion_archives.destroy_all
      subscriptions.destroy_all
      mutes.destroy_all
      blocks.destroy_all
      search_logs.destroy_all
    else
      feed_users.where.not(action_type: 'categorisation').destroy_all
      notifications.where.not(eventable_type: 'Categorisation').destroy_all
    end
  end

  def deactivate
    clear_user_data
    update_attribute(:status, :deactivated)
  end

  def reactivate
    update_attribute(:status, :active)
  end

  def self.poison_email(email, id)
    "_deleted_#{id}_#{email}"
  end

  def self.poison_username(username, id)
    "_deleted_#{id}_#{username}"
  end

  def self.poison_slug(slug, id)
    "_deleted_#{id}_#{slug}"
  end

  def delete_account(reason = 'User deleted account', by_admin = false, no_mailchimp = false)
    MailchimperService.remove_from_mailchimp_list(self) unless no_mailchimp
    clear_user_data(true)
    poisoned_email = self.class.poison_email(email, id)
    poisoned_username = self.class.poison_username(username, id)
    poisoned_slug = self.class.poison_slug(slug, id)
    skip_reconfirmation!
    email_alias_logs.create({
                              old_email: email,
                              new_email: poisoned_email,
                              old_username: username,
                              new_username: poisoned_username,
                              reason: reason
                            })
    update_attributes({
                        status: :deleted,
                        email: poisoned_email,
                        username: poisoned_username,
                        slug: poisoned_slug
                      })
    AccountDeletion.create({
                             user_id: id,
                             reason: reason,
                             by_admin: by_admin
                           })
  end

  def all_notification_settings_are_off?
    result = true
    notification_settings.each do |setting|
      result = false if setting.value != 'never'
    end
    result
  end

  def after_confirmation
    old_email = email_before_last_save
    if old_email != email
      MailchimperService.update_mailchimp_list(self, old_email, true)
      UserMailer.email_change_confirmed(self, old_email).deliver_now
    end
  end

  def mute_exchange(id)
    exchange_mutes.create({ muted_id: id })
  end

  def has_muted_own_share?(share)
    interaction_mutes.find_by(share_id: share.id).present?
  end

  def has_full_profile?
    username.present? && display_name.present? && location.present? && bio.present?
  end

  def pending_any_confirmation
    yield if !confirmed? || pending_reconfirmation?
  end

  def is_author?
    author.present?
  end

  def self.authors
    where('author_id > 0')
  end

  def self.authors_by_article_count(existing_ids, limit = 12)
    authors.includes(:author)
           .references(:author)
           .where.not(id: existing_ids)
           .order('authors.article_count desc')
           .limit(limit)
  end

  def set_all_notifications_as_old
    notifications.where(is_new: true).each do |notification|
      Notification.record_timestamps = false
      notification.update_attribute(:is_new, false)
    end
  end

  def user_cannot_be_blacklisted
    errors.add(:email, 'You cannot join TheArticle at this time') if BlackListUser.find_by(email: email)
  end

  def add_to_bibblio
    result = BibblioApiService::Users.new(self).create == true
    update_attribute(:on_bibblio, true) if result
    result
  end

  def has_default_profile_photo
    profile_photo.url == profile_photo.default_url
  end

  def delay_donation_interstitial
    DonateInterstitialImpression.create({
                                          user_id: id,
                                          shown_at: Time.now
                                        })
  end
end
