class Address < ApplicationRecord
  validates :street, :city, :zip_code, :country, presence: true
end
