class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :price
      t.integer :duration_in_days
      t.boolean :active

      t.timestamps
    end
  end
end
