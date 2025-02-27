# Every error in this app will inherit from this error, allowing us to rescue them in a specific manner.
class WeatherForecastError < StandardError
  def initialize(message)
    super(message)
  end
end
