class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  enum :status, {
    pending: 0,
    active: 1,
    canceled: 2,
    expired: 3
  }

  validates :starts_at, presence: true
  validates :ends_at, presence: true
end
