# PORO for geocoded address or location data.
class Location
  attr_reader :address, :latitude, :longitude, :zip_code

  def initialize(address: nil, latitude: nil, longitude: nil, zip_code: nil)
    @address = address
    @latitude = latitude
    @longitude = longitude
    @zip_code = zip_code
  end

  # Returns a cache key for the location based on the zip code.
  #
  # @return [String]
  #
  # @example
  #   Location.new(zip_code: "93101").cache_key
  #   # => "weather_forecast:zip_code:93101"
  def cache_key
    "weather_forecast:zip_code:#{zip_code}"
  end
end
