# Weather Forecast

A Ruby on Rails application that provides weather forecasts based on user-provided addresses. The application integrates with OpenWeather API for weather data and uses geocoding to convert addresses into coordinates.

![image](https://github.com/user-attachments/assets/a157e8d8-8842-403f-9f76-a32df76846e0)

## Technologies

- Ruby on Rails
- SQLite (database, though we don't use it)
- Redis (caching)
- HTTParty (to make OpenWeather API requests)
- Geocoder (address conversion. Uses [Nominatim](https://nominatim.org/) by default)

### Development/testing technologies

- RSpec (testing)
- Guard (spec development)
- WebMock (API mocking in tests)
- Dotenv (environment variables)
- Pry (debugger)
- Rubocop (code style)

## Prerequisites

- Ruby (check `.ruby-version` for specific version)
- Redis
- [OpenWeather API key](https://openweathermap.org/api)
  - If you don't have one, you'll need to create a free account to get one
  - NOTE: if you recently created one, it may not be immediately available. Grab a sandwich and try again later.

## Installation

### (1) Clone the repository:
```sh
git clone git@github.com:omgreenfield/weather-forecast.git
cd weather-forecast
```

### (2) Run install script
```sh
# (1) Installs dependencies
# (2) Copies .env.example to .env
# (3) Prepares the database
bin/setup
```

### (3) Start Redis server:
```sh
redis-server
```

### (4) Update `.env` with your OpenWeather API key

```sh
OPENWEATHER_API_KEY=<your-openweather-api-key>
```

## Usage

### Start development server

```sh
bin/dev
```

### Make requests from `rails console`

```sh
rails console
```

```ruby
# Grab latitude/longitude
location = GeocodingService.geocode("102 N. Hope Avenue, Santa Barbara, California")
# View cache-key (using zip code)
location.cache_key

# Get forecast
forecast = WeatherForecastService.forecast(location)

# View Redis cache contents
Rails.cache.redis.with { |conn| puts conn.keys("*") }
```

## Software design

This project consists of the following components:

- Endpoints: `app/controllers/forecasts_controller.rb`
  - `index` - Renders the address `search` partial
  - `show` - Renders both the resulting 
- Services: `app/services/`
  - `geocoding_service.rb`
    - Translates addresses or simple strings (e.g. zip code or city) into latitude/longitude
    - Caches address lookup in Redis
    - Translates looked up information into a `Location` object
  - `open_weather_adapter.rb`
    - Makes requests to the OpenWeather API
    - Caches forecast information based on zip code
    - Translate forecast information into a `Forecast` object 
  - `weather_forecast_service.rb`
    - Asks `OpenWeatherAdapter` for a forecast data based on input `Location` data
    - Uses `OpenWeatherAdapter` to make requests to the OpenWeather API
- Models (just POROs and an error): `app/models/`
  - `location.rb` - holds address, latitude/longitude, zip code, and can get a cache key based on zip code
  - `forecast.rb` - holds latitude/longitude, date/time of the forecast, temperature, feels like, humidity, low/high temperature, wind speed, and weather description (e.g. "clear sky")
  - `weather_forecast_error.rb` - a custom error for weather forecast failures. Allows us to rescue app-specific errors and unexpected errors separately
- Views: `app/views/`
  - `forecasts/`
    - `index.html.erb`     - homepage, renders a search form
    - `show.html.erb`      - renders the search form as well as location/forecast results
    - `error.html.erb`     - no different than `index`, but could add additional error handling here if we want
    - `_location.html.erb` - renders data within a `Location` object
    - `_forecast.html.erb` - renders data within a `Forecast` object
  - `layouts/`
    - `application.html.erb` - main layout with header, main, footer, and flash messages; includes Bootstrap and jQuery (not currently used), and importmap for JS
  - `shared/`
    - `_flash.html.erb` - renders flash messages

## Testing

### Run RSpec tests

```sh
bundle exec rspec
```

### Run `guard` to run specs on file change

```sh
bundle exec guard
```
