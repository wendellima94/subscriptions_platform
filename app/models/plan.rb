class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :name, presence: true
  validates :price, presence: true
  validates :duration_in_days, presence: true
end
