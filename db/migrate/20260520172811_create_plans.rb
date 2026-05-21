class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :periodicity, null: false, default: 0
      t.integer :price_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
