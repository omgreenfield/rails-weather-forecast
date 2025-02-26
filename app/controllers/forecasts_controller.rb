# frozen_string_literal: true

class ForecastsController < ApplicationController
  def index
  end

  def show
    @address = params.require(:address)

    if @address.present?
      # Geocode address
      
      flash[:info] = "Using this address: #{@address}"
    else
      flash[:error] = "Please enter an address"
      redirect_to root_path
    end
  end
end
