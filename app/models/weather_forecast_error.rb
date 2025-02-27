# Base error for all errors raised in this app.
#
# Controllers will handle these errors differently from unexpected errors.
class WeatherForecastError < StandardError
  def initialize(message)
    super(message)
  end
end
