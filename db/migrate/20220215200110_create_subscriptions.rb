# frozen_string_literal: true

# CreateSubscriptions
class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :name, null: false
      t.string :plan, null: false
      t.string :fakepay_token
      t.date :next_charge_date

      t.timestamps
    end
  end
end
