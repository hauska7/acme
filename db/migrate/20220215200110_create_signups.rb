# frozen_string_literal: true

# Create Signup
class CreateSignups < ActiveRecord::Migration[7.0]
  def change
    create_table :signups do |t|
      t.string :name
      t.string :plan
      t.string :fakepay_token

      t.timestamps
    end
  end
end
