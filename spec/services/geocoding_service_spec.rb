# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeocodingService do
  describe '.geocode' do
    let(:address) { '102 N. Hope Avenue, Santa Barbara, CA' }
    let(:mock_location) do
      double(
        address: '102 N. Hope Avenue, Santa Barbara, CA',
        state: 'California',
        latitude: 34.441858,
        longitude: -119.745803,
        postal_code: '93110'
      )
    end

    context 'with valid address' do
      before do
        allow(Geocoder).to receive(:search)
          .with(address)
          .and_return([ mock_location ])
      end

      it 'returns a Location object with correct attributes' do
        result = described_class.geocode(address)

        expect(result).to be_a(Location)
        expect(result.address).to eq('102 N. Hope Avenue, Santa Barbara, CA')
        expect(result.latitude).to eq(34.441858)
        expect(result.longitude).to eq(-119.745803)
        expect(result.zip_code).to eq('93110')
      end
    end

    context 'with nil address' do
      it 'raises NoAddressProvidedError' do
        expect {
          described_class.geocode(nil)
        }.to raise_error(
          GeocodingService::NoAddressProvidedError,
          'No address was provided'
        )
      end
    end

    context 'with non-string address' do
      it 'raises BadAddressError' do
        expect {
          described_class.geocode(123)
        }.to raise_error(
          GeocodingService::BadAddressError,
          'Expected a string address, got Integer: 123'
        )
      end
    end

    context 'when geocoding fails' do
      before do
        allow(Geocoder).to receive(:search)
          .with(address)
          .and_return([])
      end

      it 'raises CouldNotGeocodeError' do
        expect {
          described_class.geocode(address)
        }.to raise_error(
          GeocodingService::CouldNotGeocodeError,
          "Could not geocode address: #{address}"
        )
      end
    end
  end
end
