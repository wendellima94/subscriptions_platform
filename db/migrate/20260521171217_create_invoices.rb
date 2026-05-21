class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :subscription, null: false, foreign_key: true
      t.date :reference_month, null: false
      t.integer :amount_cents, null: false
      t.date :due_on, null: false
      t.datetime :paid_at
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :invoices,
              [ :subscription_id, :reference_month ],
              unique: true,
              name: "index_invoices_on_subscription_and_month"
  end
end
