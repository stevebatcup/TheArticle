class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  validates_presence_of	:first_name, :last_name, on: :create

  def self.is_username_available?(username)
    !self.find_by(username: username).present?
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
end
