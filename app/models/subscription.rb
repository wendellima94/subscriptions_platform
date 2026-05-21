class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  has_many :invoices, dependent: :destroy

  enum :status, {
    pending: 0,
    active: 1,
    canceled: 2
  }

  validates :status, presence: true
  validates :started_at, presence: true, if: :active?

  validate :only_one_active_subscription, if: :active?

  private

  def only_one_active_subscription
    return unless user_id

    active_subscription = Subscription
      .active
      .where(user_id: user_id)
      .where.not(id: id)

    errors.add(:base, "user already has an active subscription") if active_subscription.exists?
  end
end
