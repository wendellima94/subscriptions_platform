class User < ApplicationRecord
  has_secure_password

  enum :role, {
    customer: 0,
    admin: 1
  }

  has_many :subscriptions, dependent: :destroy
  has_many :invoices, through: :subscriptions

  validates :name, presence: true
  validates :email, presente: true, uniqueness: true
end
