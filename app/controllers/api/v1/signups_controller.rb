class Api::V1::SignupsController < ApplicationController
  def create
    result = CreateSignupService.call(params)


  end
end
