class Donation < ApplicationRecord
  belongs_to  :user

  def self.non_recurrring_donations_for_user(user)
    where(user_id: user.id)
      .where(recurring: false)
      .where("amount > 0.00")
      .order(created_at: :desc)
  end

  def self.recurrring_donation_for_user(user)
    find_by(user_id: user.id, recurring: true)
  end

  def cancel_recurring
    update_attributes(recurring: false, amount: 0.00)
  end

  def user_name
    user.full_name
  end
end
