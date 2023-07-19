# frozen_string_literal: true

require 'helper'

describe Quaderno::Tax do
  context 'A user with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should raise exception if token is wrong' do
      VCR.use_cassette('wrong token when requesting jurisdictions list') do
        Quaderno::Base.auth_token = '7h15154f4k370k3n'
        expect { Quaderno::TaxJurisdiction.all }.to raise_error(Quaderno::Exceptions::InvalidSubdomainOrToken)
      end
    end

    it 'should list jurisdictions' do
      VCR.use_cassette('list all jurisdictions') do
        jurisdictions = Quaderno::TaxJurisdiction.all
        expect(jurisdictions.is_a?(Array)).to be true
        expect(jurisdictions.count > 0).to be true
      end
    end

    it 'should retrieve a jurisdiction' do
      germany_id = 72

      VCR.use_cassette('retrieve german jurisdiction') do
        jurisdiction = Quaderno::TaxJurisdiction.find(germany_id)
        expect(jurisdiction.is_a?(Quaderno::TaxJurisdiction)).to be true
        expect(jurisdiction.id).to eq germany_id
        expect(jurisdiction.country).to eq 'DE'
      end
    end
  end
end
