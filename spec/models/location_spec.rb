require 'rails_helper'

RSpec.describe Location do
  describe '#cache_key' do
    it 'returns a cache key based on the zip code' do
      location = Location.new(address: '123 Memory Lane, Santa Barbara, CA', zip_code: '93101')

      expect(location.cache_key).to eq('weather_forecast:93101')
    end
  end
end
