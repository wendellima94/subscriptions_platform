class Invoice < ApplicationRecord
  belongs_to :subscription

  enum :status, {
    open: 0,
    paid: 1,
    expired: 2
  }

  validates :reference_month, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :due_on, presence: true
  validates :status, presence: true
end
