class User < ApplicationRecord
  has_secure_password

  enum :role, {
    customer: 0,
    admin: 1
  }, prefix: true

  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :invoices, through: :subscriptions

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
