require 'rails_helper'

RSpec.describe OpenWeatherAdapter do
  let(:adapter) { described_class.new }
  let(:api_key) { 'some_api_key' }
  # My old apartment in Santa Barbara
  let(:latitude) { 34.441858 }
  let(:longitude) { -119.745803 }
  let(:base_uri) { OpenWeatherAdapter::BASE_URI }
  let(:stub_query_params) { { lat: latitude, lon: longitude, units: 'imperial', appid: api_key } }
  let(:start_time) { Time.new(2025, 2, 26, 12) }
  let(:end_time) { 3.hours.after(start_time) }

  let(:weather_response) do
    {
      'coord' => { 'lat' => latitude, 'lon' => longitude },
      'dt' => start_time.to_i,
      'weather' => [ { 'description' => 'clear sky' } ],
      'main' => {
        'temp' => 79.54,
        'feels_like' => 75.54,
        'humidity' => 75,
        'temp_min' => 75.54,
        'temp_max' => 83.54
      },
      'wind' => { 'speed' => 1.99 }
    }
  end

  let(:forecast_response) do
    {
      'list' => [
        weather_response,
        weather_response.merge('dt' => end_time.to_i)
      ]
    }
  end

  before do
    allow(ENV).to receive(:fetch).with('OPENWEATHER_API_KEY', nil).and_return(api_key)
  end

  describe '#initialize' do
    context 'when API key is present' do
      it 'creates an instance with no issues' do
        expect { described_class.new }.not_to raise_error
      end
    end

    context 'when API key is missing' do
      let(:api_key) { nil }

      it 'raises NoApiKeyError' do
      expect { described_class.new }.to raise_error(
          OpenWeatherAdapter::NoApiKeyError,
          /OpenWeather API key is missing/
        )
      end
    end
  end

  describe '#weather' do
    let(:adapter) { described_class.new }

    before do
      stub_request(:get, "#{base_uri}/weather")
        .with(query: stub_query_params)
        .to_return(status: 200, body: weather_response.to_json)
    end

    it 'returns a Forecast object' do
      result = adapter.weather(latitude, longitude)

      expect(result).to be_a(Forecast)
      expect(result.latitude).to eq(latitude)
      expect(result.longitude).to eq(longitude)
      expect(result.time).to eq(start_time)
      expect(result.weather_description).to eq('clear sky')
      expect(result.temperature).to eq(79.54)
      expect(result.feels_like).to eq(75.54)
      expect(result.humidity).to eq(75)
      expect(result.temperature_low).to eq(75.54)
      expect(result.temperature_high).to eq(83.54)
      expect(result.wind_speed).to eq(1.99)
    end

    context 'when API request fails' do
      before do
        stub_request(:get, "#{base_uri}/weather")
          .with(query: stub_query_params)
          .to_return(status: 401, body: { message: 'Invalid API key' }.to_json)
      end

      it 'raises OpenWeatherApiError' do
        expect { adapter.weather(latitude, longitude) }.to raise_error(
          OpenWeatherAdapter::OpenWeatherApiError
        )
      end
    end
  end

  describe '#forecast' do
    before do
      stub_request(:get, "#{base_uri}/forecast")
        .with(query: stub_query_params)
        .to_return(status: 200, body: forecast_response.to_json)
    end

    it 'returns an array of Forecast objects' do
      results = adapter.forecast(latitude, longitude)

      expect(results).to be_an(Array)
      expect(results.length).to eq(2)
      expect(results).to all(be_a(Forecast))

      expect(results.map(&:time)).to eq([
        start_time,
        end_time
      ])
    end

    context 'when API request fails' do
      before do
        stub_request(:get, "#{base_uri}/forecast")
          .with(query: stub_query_params)
          .to_return(status: 500, body: { message: 'Server error' }.to_json)
      end

      it 'raises OpenWeatherApiError' do
        expect { adapter.forecast(latitude, longitude) }.to raise_error(
          OpenWeatherAdapter::OpenWeatherApiError
        )
      end
    end
  end

  describe '-forecast_from_response' do
    let(:adapter) { described_class.new }

    it 'returns an array of Forecast objects' do
      result = adapter.send(:forecast_from_response, forecast_response)

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result).to all(be_a(Forecast))
    end
  end

  describe '-forecast_from_response_data' do
    let(:adapter) { described_class.new }

    it 'converts OpenWeather data into a Forecast object' do
      result = adapter.send(:forecast_from_response_data, weather_response)

      expect(result).to be_a(Forecast)
      expect(result.latitude).to eq(latitude)
      expect(result.longitude).to eq(longitude)
    end

    it 'handles missing data gracefully' do
      result = adapter.send(:forecast_from_response_data, {})

      expect(result).to be_a(Forecast)
      expect(result.latitude).to be_nil
      expect(result.longitude).to be_nil
      expect(result.time).to be_nil
      expect(result.weather_description).to be_nil
    end
  end
end
