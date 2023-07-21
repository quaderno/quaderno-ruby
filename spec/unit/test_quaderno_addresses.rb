# frozen_string_literal: true

require 'helper'

describe Quaderno::Address do
  context 'when accessing a standard account' do
    before do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get an error' do
      VCR.use_cassette('all address on standard account') do
        expect { Quaderno::Address.all }.to raise_error(Quaderno::Exceptions::InvalidRequest)
      end
    end
  end

  context 'when accessing a custom account' do
    context 'using the thread-safe configuration' do
      context 'with an authentication token' do
        it 'should get all addresses (populated db)' do
          VCR.use_cassette('all addresses by authentication token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(addresses.is_a?(Array)).to be true
            addresses.each { |address| expect(address.is_a?(Quaderno::Address)).to be true }
          end
        end

        it 'should find an address' do
          VCR.use_cassette('found address by authentication token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, auth_token: TEST_KEY)
            address = Quaderno::Address.find addresses[2].id, api_url: TEST_URL, auth_token: TEST_KEY
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(addresses[2].id).to eq address.id
          end
        end

        it 'should create an address' do
          VCR.use_cassette('new address by authentication token') do
            address = Quaderno::Address.create(street_line_1: 'Test_Address 2 line 1', street_line_2: 'Test_Address 2 line 2', postal_code: '1234', city: 'TCity', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(address.street_line_1).to eq 'Test_Address 2 line 1'
            expect(address.street_line_2).to eq 'Test_Address 2 line 2'
            expect(address.postal_code).to eq '1234'
            expect(address.city).to eq 'TCity'
          end
        end

        it 'should update an address' do
          VCR.use_cassette('updated address by authentication token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, auth_token: TEST_KEY)
            address = Quaderno::Address.update(addresses[2].id, street_line_1: 'New test address 2', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(address.street_line_1).to eq 'New test address 2'
          end
        end
      end

      context 'with an OAuth 2.0 access token' do
        it 'should get all addresses (populated db)' do
          VCR.use_cassette('all addresses by authentication token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(addresses.is_a?(Array)).to be true
            addresses.each { |address| expect(address.is_a?(Quaderno::Address)).to be true }
          end
        end

        it 'should find an address' do
          VCR.use_cassette('found address by access token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            address = Quaderno::Address.find addresses[2].id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(addresses[2].id).to eq address.id
          end
        end

        it 'should create an address' do
          VCR.use_cassette('new address by access token') do
            address = Quaderno::Address.create(street_line_1: 'Test_Address 1 line 1', street_line_2: 'Test_Address 1 line 2', postal_code: '1234', city: 'TCity', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(address.street_line_1).to eq 'Test_Address 1 line 1'
            expect(address.street_line_2).to eq 'Test_Address 1 line 2'
            expect(address.postal_code).to eq '1234'
            expect(address.city).to eq 'TCity'
          end
        end

        it 'should update an address' do
          VCR.use_cassette('updated address by access token') do
            addresses = Quaderno::Address.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            address = Quaderno::Address.update(addresses[2].id, street_line_1: 'New test address 1', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
            expect(address.is_a?(Quaderno::Address)).to be true
            expect(address.street_line_1).to eq 'New test address 1'
          end
        end
      end
    end
  end
end
