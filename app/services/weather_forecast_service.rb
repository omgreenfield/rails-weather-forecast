# frozen_string_literal: true

class WeatherForecastService
  CACHE_EXPIRATION = 30.minutes

  # Syntactic sugar for `new.forecast(location)`
  #
  # @param location [Location]
  # @return [Forecast]
  def self.forecast(location)
    new.forecast(location)
  end

  # Get weather forecast from location's latitude and longitude
  #
  # @param location [Location]
  # @return [Forecast]
  #
  # @example
  #   WeatherForecastService.forecast(Location.new(latitude: 34.441858, longitude: -119.745803))
  def forecast(location)
    # I don't know what's going on here, but `location.is_a?(Location)` has returned false multiple times.
    # Could be Spring-related? Comparing `class.name` instead.
    raise ArgumentError, "Expected Location object, got #{location.class}: #{location.inspect}" unless location.class.name == 'Location'

    Rails.cache.fetch(location.cache_key, expires_in: CACHE_EXPIRATION) do
      query(location)
    end
  end

  private

  # See {OpenWeatherAdapter#query}
  #
  # @param location [Location]
  # @return [Forecast]
  def query(location)
    adapter.query('weather', location.latitude, location.longitude)
  end

  def adapter
    @adapter ||= OpenWeatherAdapter.new
  end
end
