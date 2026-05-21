class User < ApplicationRecord
  has_secure_password

  enum :role, {
    customer: 0,
    admin: 1
  }, prefix: true

  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :invoices, through: :subscriptions

  before_create :generate_api_token

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :api_token, uniqueness: true, allow_nil: true

  private

  def generate_api_token
    self.api_token ||= SecureRandom.hex(24)
  end
end
