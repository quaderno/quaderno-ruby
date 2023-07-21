# frozen_string_literal: true

require 'helper'

describe Quaderno::TaxCode do
  context 'A user with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should raise exception if token is wrong' do
      VCR.use_cassette('wrong token when requesting tax codes list') do
        Quaderno::Base.auth_token = '7h15154f4k370k3n'
        expect { Quaderno::TaxCode.all }.to raise_error(Quaderno::Exceptions::InvalidSubdomainOrToken)
      end
    end

    it 'should list jurisdictions' do
      VCR.use_cassette('list all tax codes') do
        jurisdictions = Quaderno::TaxCode.all
        expect(jurisdictions.is_a?(Array)).to be true
        expect(jurisdictions.count > 0).to be true
      end
    end

    it 'should retrieve a jurisdiction' do
      VCR.use_cassette('retrieve saas tax code') do
        jurisdiction = Quaderno::TaxCode.find('saas')
        expect(jurisdiction.is_a?(Quaderno::TaxCode)).to be true
      end
    end
  end
end
