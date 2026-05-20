class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true
end
