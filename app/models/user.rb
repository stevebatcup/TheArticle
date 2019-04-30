class User < ApplicationRecord
  # POPULAR_FOLLOW_COUNT = 5
  # Include default devise modules. Others available are:
  # :lockable and :omniauthable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :confirmable, :trackable, :rememberable

  validates_presence_of	:first_name, :last_name, on: :create
  enum  status: [:active, :deactivated, :deleted]
  enum  admin_level: [:nothing, :admin, :super_admin]

  has_many  :subscriptions
  has_many  :exchanges, through: :subscriptions

  before_create :assign_default_profile_photo_id
  after_create :assign_default_settings
  before_save :downcase_username
  mount_base64_uploader :profile_photo, ProfilePhotoUploader, file_name: -> (u) { u.photo_filename(:profile) }
  mount_base64_uploader :cover_photo, CoverPhotoUploader, file_name: -> (u) { u.photo_filename(:cover) }

  # people I follow
  has_many :followings, class_name: "Follow"

  # people who follow me
  has_many :fandoms, class_name: "Follow", foreign_key: :followed_id
  has_many :followers, through: :fandoms, source: :user

  has_many :profile_suggestions
  has_many :shares
  has_many :search_logs
  has_many :comments
  has_many :opinions
  has_many :feeds
  has_many :notifications
  has_many :concern_reports, as: :sourceable

  has_many  :mutes
  has_many  :blocks

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

  belongs_to   :author, optional: true

  include Suggestable
  include Shareable
  include Followable
  include Opinionable
  include Adminable
  include Mailable

  attr_writer :login

  def remember_me
    true
  end

  def downcase_username
    self.username = self.username.downcase
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def assign_default_settings
    self.username = generate_usernames.first
    self.display_name = "#{first_name} #{last_name}"
    self.slug = self.username.downcase

    self.notification_settings.build({ key: 'email_followers', value: 'daily' })
    self.notification_settings.build({ key: 'email_exchanges', value: 'daily' })
    self.notification_settings.build({ key: 'email_responses', value: 'never' })
    self.notification_settings.build({ key: 'email_replies', value: 'never' })

    self.communication_preferences.build({ preference: 'newsletters_weekly', status: true })
    self.communication_preferences.build({ preference: 'newsletters_offers', status: true })
    self.save
  end

  def set_opted_into_weekly_newsletters(status)
    self.communication_preferences.where(preference: :newsletters_weekly).update_attribute(status)
  end

  def set_opted_into_offers(status)
    self.communication_preferences.where(preference: :newsletters_offers).update_attribute(status)
  end

  def self.active
    where(status: :active, has_completed_wizard: true)
  end

  def has_active_status?
    [:active, :deactivated].include?(self.status.to_sym)
  end

  def active_for_authentication?
    super && has_active_status?
  end

  def inactive_message
    has_active_status? ? super : :account_deleted
  end

  def full_name
    account_name
  end

  def account_name
    "#{self.first_name} #{self.last_name}"
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
    "#{type}_photo_#{self.id}_#{Time.now.to_i}"
  end

  def assign_default_profile_photo_id
    self.default_profile_photo_id = rand(1..75)
  end

  def default_display_name
  	"#{first_name.strip} #{last_name.strip}".gsub(/[^a-z_\'\- ]/i, '')
  end

  def generate_usernames(amount=1)
  	items = []
    username = ""
    i = 0
    amount.times do
      begin
        username = "#{first_name.downcase.strip}#{last_name.downcase.strip}#{i > 0 ? i : ''}"
        username = username.gsub(/[^0-9a-z_ ]/i, '')
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
    self.lat = params[:location][:lat]
    self.lng = params[:location][:lng]
    self.country_code = params[:location][:country_code]
    existing_exchange_ids = self.exchanges.map(&:id)
    params[:selected_exchanges].each do |eid|
      unless existing_exchange_ids.include?(eid)
        self.exchanges << Exchange.find(eid)
      end
    end
    editor_exchange = Exchange.editor_item
    self.exchanges << editor_exchange unless existing_exchange_ids.include?(editor_exchange.id)
    self.has_completed_wizard = 1
    self.save
  end

  def self.popular_users(excludes=[], popular_follow_count=5, amount=10)
    self.active.joins(:followers)
          .where.not(id: excludes)
          .group("users.id")
          .order("count(follows.user_id) DESC")
          .having("count(follows.user_id) >= #{popular_follow_count}")
          .limit(amount)
  end

  def self.bio_max_length
    180
  end

  def self.is_username_available?(username)
    !self.find_by(username: username).present?
  end

  def update_notification_counter_cache
    # count = Notification.get_new_count_for_user(self, true)
    count = self.notifications.where(is_new: true).size
    self.update_attribute(:notification_counter_cache, count)
  end

  def has_muted(user)
    muted_id_list.include?(user.id)
  end

  def muted_list
    @muted_list ||= self.mutes.where(status: :active)
  end

  def muted_id_list
    @muted_id_list ||= muted_list.map(&:muted_id)
  end

  def has_blocked(user)
    blocked_id_list.include?(user.id)
  end

  def blocked_list
    @blocked_list ||= self.blocks.where(status: :active)
  end

  def blocked_id_list
    @blocked_id_list ||= blocked_list.map(&:blocked_id)
  end

  def is_comment_disallowed?(comment)
    if self.has_blocked(comment.user)
      true
    elsif comment.user.has_blocked(self)
      true
    else
      blocked_usernames = self.blocked_list.map(&:blocked).map(&:username)
      blocked_usernames.any? {|username| comment.body.include?(username)}
    end
  end

  def profile_is_deactivated?
    self.status.to_sym == :deactivated
  end

  def clear_user_data(deleting_account=false)
    self.notifications.destroy_all
    self.followings.destroy_all
    self.fandoms.destroy_all
    self.shares.destroy_all
    self.comments.destroy_all
    self.feeds.destroy_all
    self.opinions.destroy_all
    self.quarantined_third_party_shares.destroy_all
    ProfileSuggestion.delete_suggested(self)
    if deleting_account
      self.profile_suggestions.destroy_all
      self.subscriptions.destroy_all
      self.mutes.destroy_all
      self.blocks.destroy_all
      self.search_logs.destroy_all
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

  def delete_account(reason="User deleted account", by_admin=false)
    MailchimperService.remove_from_mailchimp_list(self)
    clear_user_data(true)
    poisoned_email = self.class.poison_email(self.email, self.id)
    poisoned_username = self.class.poison_username(self.username, self.id)
    skip_reconfirmation!
    self.email_alias_logs.create({
      old_email: self.email,
      new_email: poisoned_email,
      old_username: self.username,
      new_username: poisoned_username,
      reason: reason
    })
    update_attributes({
      status: :deleted,
      email: poisoned_email,
      username: poisoned_username
    })
    AccountDeletion.create({
      user_id: self.id,
      reason: reason,
      by_admin: by_admin
    })
  end

  def all_notification_settings_are_off?
    result = true
    self.notification_settings.each do |setting|
      result = false if setting.value != 'never'
    end
    result
  end

  def after_confirmation
    old_email = self.email_before_last_save
    if old_email != self.email
      UserMailer.email_change_confirmed(self, old_email).deliver_now
    else
      UserMailer.first_confirmed(self).deliver_now
    end
  end

  def mute_exchange(id)
    self.exchange_mutes.create({muted_id: id})
  end

  def has_muted_own_share?(share)
    self.interaction_mutes.find_by(share_id: share.id).present?
  end

  def has_full_profile?
    self.username.present? && self.display_name.present? && self.location.present? && self.bio.present?
  end

  def pending_any_confirmation
    if (!confirmed? || pending_reconfirmation?)
      yield
    end
  end

end