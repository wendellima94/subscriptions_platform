class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  enum :periodicity, {
    monthly: 0,
    quarterly: 1
  }

  validates :name, presence: true
  validates :periodicity, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [ true, false ] }
end
