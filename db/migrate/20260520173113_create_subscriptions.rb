class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.integer :status
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
