# frozen_string_literal: true

# Service for geocoding addresses.
class GeocodingService
  class << self
    # Translate address or location information into a Location object.
    #
    # @param address [String]
    # @return [Location]
    # @raise [NoAddressProvidedError] if no address is provided
    # @raise [BadAddressError] if the address is not a string
    #
    # @example - full address
    #   GeocodingService.geocode('102 N. Hope Avenue, Santa Barbara, California')
    #
    # @example - just zip code
    #   GeocodingService.geocode('93101')
    def geocode(address)
      raise NoAddressProvidedError if address.nil?
      raise BadAddressError, address unless address.is_a?(String)

      # Trying out `then` (AKA `yield_self`) to see if I like it
      result_from_address(address).then do |data|
        location_from_result(data)
      end
    end

    # Translate results from geocoder API into a Location object.
    #
    # @param data [Geocoder::Result]
    # @return [Location]
    def location_from_result(data)
      Location.new(
        address: data.address,
        latitude: data.latitude,
        longitude: data.longitude,
        zip_code: data.postal_code,
      )
    end

    # Makes request to geocoder API and returns results. Defaults to US.
    #
    # @param address [String]
    # @return [Geocoder::Result]
    #
    # @raise [CouldNotGeocodeError] if the address could not be geocoded
    def result_from_address(address)
      results = Geocoder.search(address, params: { countrycodes: 'US' })

      raise CouldNotGeocodeError, address if results.empty?

      # For now, just return the first result.
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
      super('No address was provided')
    end
  end

  class CouldNotGeocodeError < WeatherForecastError
    def initialize(address)
      super("Could not geocode address: #{address}")
    end
  end
end
