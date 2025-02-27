# frozen_string_literal: true

class ForecastsController < ApplicationController
  def index
  end

  def show
    @address = params.require(:address)

    raise WeatherForecastError, 'Please enter an address' unless @address.present?

    @location = GeocodingService.geocode(@address)
    @forecast = WeatherForecastService.forecast(@location)
  rescue WeatherForecastError => e
    flash[:error] = e.message

    render :error, status: :unprocessable_entity
  rescue StandardError => e
    flash[:error] = e.message

    render :error, status: :internal_server_error
  end
end
