# frozen_string_literal: true

# Create Address
class CreateAddress < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :street, null: false
      t.string :city, null: false
      t.string :zip_code, null: false
      t.string :country, null: false

      t.timestamps
    end

    add_reference(:subscriptions, :shipping_address, index: true, foreign_key: { to_table: :addresses }, null: false)
  end
end
