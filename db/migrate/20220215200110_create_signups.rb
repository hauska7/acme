# frozen_string_literal: true

# Create Signup
class CreateSignups < ActiveRecord::Migration[7.0]
  def change
    create_table :signups do |t|
      t.string :name, null: false
      t.string :plan, null: false
      t.string :fakepay_token

      t.timestamps
    end
  end
end
