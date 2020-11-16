class Donation < ApplicationRecord
  belongs_to  :user
  enum status: [:paid, :paying, :cancelled]

  before_create :set_status

  def self.non_recurrring_donations_for_user(user)
    where(user_id: user.id)
      .where(recurring: false)
      .where(status: :paid)
      .order(created_at: :desc)
  end

  def self.recurrring_donation_for_user(user)
    find_by(user_id: user.id, recurring: true)
  end

  def set_status
    self.status = recurring ? :paying : :paid
  end

  def cancel_recurring
    update_attributes(status: :cancelled)
  end

  def user_name
    user.full_name
  end
end
