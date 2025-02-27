# frozen_string_literal: true

class GeocodingService
  class << self
    def geocode(address)
      raise NoAddressProvidedError if address.nil?
      raise BadAddressError, address unless address.is_a?(String)

      # Trying out `then` (AKA `yield_self`) to see if I like it
      result_from_address(address).then do |data|
        location_from_result(data)
      end
    end

    def location_from_result(data)
      Location.new(
        address: data.address,
        latitude: data.latitude,
        longitude: data.longitude,
        zip_code: data.postal_code,
      )
    end

    def result_from_address(address)
      results = Geocoder.search(address, params: { countrycodes: "US" })

      raise CouldNotGeocodeError, address if results.empty?

      # Haven't yet determined significant of multiple responses from Geocoder.
      results.first
    end
  end

  class BadAddressError < WeatherForecastError
    def initialize(address)
      super("Expected a string address, got #{address.class}: #{address}")
    end
  end

  class NoAddressProvidedError < WeatherForecastError
    def initialize
      super("No address was provided")
    end
  end

  class CouldNotGeocodeError < WeatherForecastError
    def initialize(address)
      super("Could not geocode address: #{address}")
    end
  end
end

