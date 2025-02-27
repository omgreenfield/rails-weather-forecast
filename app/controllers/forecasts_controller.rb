# frozen_string_literal: true

class ForecastsController < ApplicationController
  def index
  end

  def show
    @address = params.require(:address)

    unless @address.present?
      flash[:error] = "Please enter an address"

      redirect_to root_path
      return
    end

    @location = GeocodingService.geocode(@address)
    @forecast = WeatherForecastService.forecast(@location)
  end
end
