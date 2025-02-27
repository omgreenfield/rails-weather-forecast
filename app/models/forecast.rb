# PORO for forecast data from OpenWeather API.
class Forecast
  attr_reader :latitude, :longitude, :time, :temperature, :feels_like, :humidity, :temperature_low, :temperature_high, :wind_speed, :weather_description

  def initialize(latitude:, longitude:, time:, temperature:, feels_like:, humidity:, temperature_low:, temperature_high:, wind_speed:, weather_description:)
    @latitude = latitude
    @longitude = longitude
    @time = time
    @temperature = temperature
    @feels_like = feels_like
    @humidity = humidity
    @temperature_low = temperature_low
    @temperature_high = temperature_high
    @wind_speed = wind_speed
    @weather_description = weather_description
  end
end
