# frozen_string_literal: true

require 'helper'

describe Quaderno::TaxId do
  let(:france_id) { 11 }
  let(:italy_id) { 68 }

  context 'using the default configuration with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all tax ids (populated db)' do
      VCR.use_cassette('all tax ids') do
        tax_ids = Quaderno::TaxId.all
        expect(tax_ids.empty?).to be false
        expect(tax_ids.is_a?(Array)).to be true
        tax_ids.each { |tax_id| expect(tax_id.is_a?(Quaderno::TaxId)).to be true }
      end
    end

    it 'should find a tax id' do
      VCR.use_cassette('found tax id') do
        tax_ids = Quaderno::TaxId.all
        tax_id = Quaderno::TaxId.find tax_ids[2].id
        expect(tax_id.is_a?(Quaderno::TaxId)).to be true
        expect(tax_ids[2].id).to eq tax_id.id
      end
    end

    it 'should create a tax id' do
      VCR.use_cassette('new tax_id') do
        tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03')
        expect(tax_id.is_a?(Quaderno::TaxId)).to be true
        expect(tax_id.jurisdiction['country']).to eq 'FR'
        expect(tax_id.valid_from).to eq '2018-01-03'
      end
    end

    it 'should update a tax id' do
      VCR.use_cassette('updated tax id') do
        tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03')
        tax_id = Quaderno::TaxId.update(tax_id.id, value: '2222222222', valid_until: '2023-04-01')
        expect(tax_id.is_a?(Quaderno::TaxId)).to be true
        expect(tax_id.valid_until).to eq '2023-04-01'
        expect(tax_id.value).to eq '2222222222'
      end
    end

    it 'should delete a tax id' do
      VCR.use_cassette('deleted tax id') do
        new_tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: italy_id)
        tax_ids_before = Quaderno::TaxId.all.map(&:id)
        expect(tax_ids_before.include?(new_tax_id.id)).to be true

        Quaderno::TaxId.delete new_tax_id.id

        tax_ids_after = Quaderno::TaxId.all
        expect(tax_ids_after.include?(new_tax_id.id)).to be false
      end
    end

    it 'should validate a tax id' do
      VCR.use_cassette('validate tax id') do
        result = Quaderno::TaxId.validate('IE', 'IE9825613N')
        expect(result.valid).to be true

        result = Quaderno::TaxId.validate('IE', '123456789U')
        expect(result.valid).to be false
      end
    end

    it 'should know the rate limit' do
      VCR.use_cassette('rate limit') do
        result = Quaderno::Base.rate_limit_info
        expect(result.rate_limit_info[:remaining] < 2000).to be true
      end
    end
  end

  context 'using the thread-safe configuration' do
    context 'with an authentication token' do
      it 'should get all tax ids (populated db)' do
        VCR.use_cassette('all tax ids by authentication token') do
          tax_ids = Quaderno::TaxId.all(api_url: TEST_URL, auth_token: TEST_KEY)
          expect(tax_ids.is_a?(Array)).to be true
          tax_ids.each { |tax_id| expect(tax_id.is_a?(Quaderno::TaxId)).to be true }
        end
      end

      it 'should find a tax id' do
        VCR.use_cassette('found tax id by authentication token') do
          tax_ids = Quaderno::TaxId.all(api_url: TEST_URL, auth_token: TEST_KEY)
          tax_id = Quaderno::TaxId.find tax_ids[2].id, api_url: TEST_URL, auth_token: TEST_KEY
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_ids[2].id).to eq tax_id.id
        end
      end

      it 'should create a tax id' do
        VCR.use_cassette('new tax id by authentication token') do
          tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_id.jurisdiction['country']).to eq 'FR'
          expect(tax_id.valid_from).to eq '2018-01-03'
        end
      end

      it 'should update a tax id' do
        VCR.use_cassette('updated tax id by authentication token') do
          tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03', api_url: TEST_URL, auth_token: TEST_KEY)
          tax_id = Quaderno::TaxId.update(tax_id.id, value: '2222222222', valid_until: '2023-04-01', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_id.valid_until).to eq '2023-04-01'
          expect(tax_id.value).to eq '2222222222'
        end
      end

      it 'should validate a tax id' do
        VCR.use_cassette('validate tax id by authentication token') do
          result = Quaderno::TaxId.validate('IE', 'IE9825613N', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(result.valid).to be true

          result = Quaderno::TaxId.validate('IE', '123456789U', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(result.valid).to be false
        end
      end

      it 'should delete a tax id' do
        VCR.use_cassette('deleted tax id by authentication token') do
          new_tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: italy_id, api_url: TEST_URL, auth_token: TEST_KEY)
          tax_ids_before = Quaderno::TaxId.all(api_url: TEST_URL, auth_token: TEST_KEY).map(&:id)
          expect(tax_ids_before.include?(new_tax_id.id)).to be true

          Quaderno::TaxId.delete(new_tax_id.id, api_url: TEST_URL, auth_token: TEST_KEY)

          tax_ids_after = Quaderno::TaxId.all(api_url: TEST_URL, auth_token: TEST_KEY)
          expect(tax_ids_after.include?(new_tax_id.id)).to be false
        end
      end
    end

    context 'with an OAuth 2.0 access token' do
      it 'should get all tax ids (populated db)' do
        VCR.use_cassette('all tax ids by access token') do
          tax_ids = Quaderno::TaxId.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(tax_ids.is_a?(Array)).to be true
          tax_ids.each { |tax_id| expect(tax_id.is_a?(Quaderno::TaxId)).to be true }
        end
      end

      it 'should find a tax id' do
        VCR.use_cassette('found tax id by access token') do
          tax_ids = Quaderno::TaxId.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          tax_id = Quaderno::TaxId.find tax_ids[2].id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_ids[2].id).to eq tax_id.id
        end
      end

      it 'should create a tax id' do
        VCR.use_cassette('new tax_id by access token') do
          tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_id.jurisdiction['country']).to eq 'FR'
          expect(tax_id.valid_from).to eq '2018-01-03'
        end
      end

      it 'should update a tax id' do
        VCR.use_cassette('updated tax id by access token') do
          tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: france_id, valid_from: '2018-01-03', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          tax_id = Quaderno::TaxId.update(tax_id.id, value: '2222222222', valid_until: '2023-04-01', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(tax_id.is_a?(Quaderno::TaxId)).to be true
          expect(tax_id.valid_until).to eq '2023-04-01'
          expect(tax_id.value).to eq '2222222222'
        end
      end

      it 'should delete a tax id' do
        VCR.use_cassette('deleted tax id by access token') do
          new_tax_id = Quaderno::TaxId.create(value: '1111111', jurisdiction_id: italy_id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          tax_ids_before = Quaderno::TaxId.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN).map(&:id)
          expect(tax_ids_before.include?(new_tax_id.id)).to be true

          Quaderno::TaxId.delete(new_tax_id.id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)

          tax_ids_after = Quaderno::TaxId.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(tax_ids_after.include?(new_tax_id.id)).to be false
        end
      end

      it 'should validate a tax id' do
        VCR.use_cassette('validate tax id by access token') do
          result = Quaderno::TaxId.validate('IE', 'IE9825613N', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(result.valid).to be true

          result = Quaderno::TaxId.validate('IE', '123456789U', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(result.valid).to be false
        end
      end
    end
  end
end
