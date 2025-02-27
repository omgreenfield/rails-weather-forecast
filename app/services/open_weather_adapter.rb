# frozen_string_literal: true

class OpenWeatherAdapter
  include HTTParty
  BASE_URI = 'https://api.openweathermap.org/data/2.5'
  base_uri BASE_URI

  def initialize
    @api_key = ENV.fetch('OPENWEATHER_API_KEY', nil)
    raise NoApiKeyError unless @api_key
  end

  # Queries OpenWeather for the current weather data and convert to a Forecast PORO.
  #
  # @param latitude [Float]
  # @param longitude [Float]
  # @return [Forecast]
  #
  # @example
  #   OpenWeatherAdapter.new.weather(34.441858, -119.745803)
  def weather(latitude, longitude)
    query('weather', latitude, longitude)
  end

  # Queries OpenWeather for the forecast data and convert to an array of Forecast POROs.
  #
  # @param latitude [Float]
  # @param longitude [Float]
  # @return [Array<Forecast>]
  #
  # @example
  #   OpenWeatherAdapter.new.forecast(34.441858, -119.745803)
  def forecast(latitude, longitude)
    query('forecast', latitude, longitude)
  end

  # Queries OpenWeather for the data and convert to a Forecast PORO.
  #
  # @param endpoint [String]
  # @param latitude [Float]
  # @param longitude [Float]
  # @return [Forecast]
  #
  # @example
  #   OpenWeatherAdapter.new.query('weather', 34.441858, -119.745803)
  def query(endpoint, latitude, longitude)
    response = self.class.get("/#{endpoint}", query: {
      lat: latitude,
      lon: longitude,
      appid: api_key,
      units: 'imperial',
    })

    raise OpenWeatherApiError, response unless response.success?

    forecast_from_response(JSON.parse(response.body))
  rescue JSON::ParserError
    raise ParseError, response
  end

  private

  # Converts OpenWeather response data into a Forecast PORO.
  #
  # If response has 'list' key (i.e. when from a forecast), map each item to a Firecast
  #
  # @param response [Hash]
  # @return [Forecast | Array<Forecast>]
  def forecast_from_response(response)
    if response['list'].present?
      response['list'].map(&method(:forecast_from_response_data))
    else
      forecast_from_response_data(response)
    end
  end

  # Converts OpenWeather response data into a Forecast PORO.
  #
  # @param data [Hash]
  # @return [Forecast]
  def forecast_from_response_data(data)
    Forecast.new(
      latitude: data.dig('coord', 'lat'),
      longitude: data.dig('coord', 'lon'),
      time: (Time.at(data.dig('dt')) rescue nil),
      weather_description: data.dig('weather', 0, 'description'),
      temperature: data.dig('main', 'temp'),
      feels_like: data.dig('main', 'feels_like'),
      humidity: data.dig('main', 'humidity'),
      temperature_low: data.dig('main', 'temp_min'),
      temperature_high: data.dig('main', 'temp_max'),
      wind_speed: data.dig('wind', 'speed'),
    )
  end

  private

  attr_reader :api_key

  public

  class ParseError < StandardError
    def initialize(response)
      super("Unable to parse response from OpenWeather: #{response}")
    end
  end

  class OpenWeatherApiError < StandardError
    def initialize(response)
      super("OpenWeather API error: #{response}")
    end
  end
  
  class NoApiKeyError < StandardError
    def initialize
      super('OpenWeather API key is missing. Please set OPENWEATHER_API_KEY environment variable. Visit https://openweathermap.org/api to get an API key.')
    end
  end
end
