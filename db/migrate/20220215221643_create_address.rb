# frozen_string_literal: true

# Create Address
class CreateAddress < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :zip_code
      t.string :country

      t.timestamps
    end

    add_reference(:signups, :shipping_address, index: true, foreign_key: { to_table: :addresses }, null: false)
  end
end
