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
