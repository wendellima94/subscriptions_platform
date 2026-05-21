class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :subscriptions,
              :user_id,
              unique: true,
              where: "status = 1",
              name: "index_subscriptions_on_active_user"
  end
end
