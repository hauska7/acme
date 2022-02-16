# frozen_string_literal: true

class Address < ApplicationRecord
  validates :street, :city, :zip_code, :country, presence: true
end
