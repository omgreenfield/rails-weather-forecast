# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherForecastService do
  let(:service) { described_class.new }
  let(:latitude) { 34.441858 }
  let(:longitude) { -119.745803 }
  let(:location) { Location.new(latitude: latitude, longitude: longitude) }
  let(:adapter) { instance_double(OpenWeatherAdapter) }
  let(:forecast_data) { instance_double(Forecast) }

  before do
    Rails.cache.clear
    allow(OpenWeatherAdapter).to receive(:new).and_return(adapter)
    allow(adapter).to receive(:query).and_return(forecast_data)
  end

  describe '.forecast' do
    it 'delegates to instance method' do
      expect_any_instance_of(described_class).to receive(:forecast).with(location)
      described_class.forecast(location)
    end
  end

  describe '#forecast' do
    context 'with valid location' do
      it 'returns forecast data' do
        expect(service.forecast(location)).to eq(forecast_data)
      end

      it 'sends a query to the adapter' do
        expect(adapter).to receive(:query).with('weather', latitude, longitude)
        service.forecast(location)
      end
    end

    it 'returns cached results if available' do
      expect(adapter).to receive(:query).once
      
      2.times { service.forecast(location) }
    end

    context 'with invalid location' do
      let(:invalid_location) { { latitude: 123, longitude: 234 } }

      it 'raises ArgumentError' do
        expect { service.forecast(invalid_location) }
          .to raise_error(ArgumentError, "Expected Location object, got Hash: {latitude: 123, longitude: 234}")
      end
    end
  end
end
