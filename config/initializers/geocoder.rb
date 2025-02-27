Geocoder.configure(
  cache: Rails.cache,
  cache_options: {
    expires_in: 24.hours,
    prefix: 'geocoder:'
  }
)
