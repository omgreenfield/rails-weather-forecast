# Weather Forecast Rails App

_By Matthew Greenfield_

## Installation process

### Commands to get set up

```sh
# Might not need postgres, but I prefer that over sqlite
# Will use RSpec
rails new weather-forecast -T -d postgresql

# Add test gems
bundle add -g test rspec-rails factory_bot_rails faker shoulda-matchers

# Add debugging gems
bundle add -g development,test pry-rails pry-byebug pry-stack_explorer dotenv-rails

# Add gems for caching, making API calls to OpenWeather, and geocoding
bundle add redis httparty geocoder
```

### Cleaning up the `Gemfile`

- Moved gems into group blocks rather than individual `gem 'thing', group: :thing` calls
- Removed:
  - `kamal` - Default `Dockerfile` works well with Railway fine
  - `jbuilder` - Not needed here
  - `solid_cache` - DB backed caching. Will use Redis instead
  - `solid_queue` - DB backed queueing. Don't think we'll have any jobs. We'll find out
  - `solid_cable` - Not going to use ActionCable here

### Design/brainstorming

- Routes/controller actions
  - Root to `GET forecasts` => `forecasts#index` to enter address info
  - Route `GET forecast` => `forecasts#show`
    - Maybe use AJAX with a flash partial
- Controller actions
  - `index`
    - Show form
    - On submit, hit `show`
  - `show`
    - Param validation
      - Start with `params.require('zip')` to ensure we always have one rather than making the Geocoder guess
    - Get forecast for address info
- Getting forecast
  - Assuming we have `zipcode`, check cache and return values
    - Instructions point out a bonus for high/low and extended
      - Not sure if there's something deeper here, but OpenWeather has endpoints for this 🤷‍♂️
    - This can be a service
  - If cache misses
    - Send address info to Geocoder, return lat/long
      - Another service
    - Forward lat/long to OpenWeather API
      - Grab forecast data
      - Cache it
      - Return it
      - Render view
      - Another service

This will likely change as I work through it, but it's a start. Time to code.
