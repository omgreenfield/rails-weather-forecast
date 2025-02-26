# frozen_string_literal: true

class GeocodingService
  # @param address [String]
  # @return [Location]
  def self.geocode(address)
    raise NoAddressProvidedError if address.nil?
    raise BadAddressError, address unless address.is_a?(String)

    results = Geocoder.search(address)
    
    raise CouldNotGeocodeError, address if results.empty?
    
    location_data = results.first

    Location.new(
      address: location_data.address, 
      latitude: location_data.latitude,
      longitude: location_data.longitude,
      zip_code: location_data.postal_code,
    )
  end

  class BadAddressError < ArgumentError
    def initialize(address)
      super("Expected a string address, got #{address.class}: #{address}")
    end
  end

  class NoAddressProvidedError < StandardError
    def initialize
      super("No address was provided")
    end
  end

  class CouldNotGeocodeError < StandardError
    def initialize(address)
      super("Could not geocode address: #{address}")
    end
  end
end

