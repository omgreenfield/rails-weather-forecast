class Location
  attr_reader :address, :latitude, :longitude, :zip_code

  def initialize(address: nil, latitude: nil, longitude: nil, zip_code: nil)
    @address = address
    @latitude = latitude
    @longitude = longitude
    @zip_code = zip_code
  end

  def cache_key
    "weather_forecast:#{zip_code}"
  end
end
