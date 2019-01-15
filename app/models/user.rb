class User < ApplicationRecord
  POPULAR_FOLLOW_COUNT = 5
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable, :rememberable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :confirmable, :trackable

  validates_presence_of	:first_name, :last_name, on: :create

  has_many  :subscriptions
  has_many  :exchanges, through: :subscriptions

  before_create :assign_default_profile_photo_id
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

  include Suggestable
  include Shareable
  include Followable

  def set_ip_data(request)
    ip = request.remote_ip
    # ip = '86.150.196.99'
    self.update_attribute(:signup_ip_address, ip)
    if geo_info = Geocoder.search(ip).first
      self.update_attributes({
        signup_ip_city: geo_info.city,
        signup_ip_region: geo_info.region,
        signup_ip_country: geo_info.country
      })
    end
  end

  def photo_filename(type)
    "#{type}_photo_#{self.id}_#{Time.now.to_i}"
  end

  def assign_default_profile_photo_id
    self.default_profile_photo_id = rand(1..10)
  end

  def default_display_name
  	"#{first_name} #{last_name}"
  end

  def generate_usernames(amount=1)
  	items = []
    username = ""
    i = 1
    amount.times do
      begin
        username = "#{first_name.capitalize}#{last_name.capitalize}#{i}"
        i += 1
      end while !self.class.is_username_available?("@#{username}") || items.include?(username)
      items << username
    end
    items
  end

  def complete_profile_from_wizard(params)
    self.display_name = params[:names][:display_name][:value]
    self.username = "@#{params[:names][:username][:value]}"
    self.slug = self.username.downcase
    self.location = params[:location][:value]
    self.lat = params[:location][:lat]
    self.lng = params[:location][:lng]
    self.country_code = params[:location][:country_code]
    params[:selected_exchanges].each do |eid|
      self.exchanges << Exchange.find(eid)
    end
    self.has_completed_wizard = 1
    self.save
  end

  def self.popular_users(excludes=[])
    self.joins(:followers)
          .where.not(id: excludes)
          .group("users.id")
          .having("count(follows.user_id) >= #{POPULAR_FOLLOW_COUNT}")
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
end