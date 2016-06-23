require 'helper'

class TestQuadernoTax < Test::Unit::TestCase
  context 'A user with an authenticate token with webhooks' do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    should 'raise exception if pass wrong arguments' do
      assert_raise ArgumentError do
        Quaderno::Tax.calculate 1, 2, 3
      end
    end

    should 'raise exception if token is wrong' do
      VCR.use_cassette('wrong token') do
        assert_raise Quaderno::Exceptions::InvalidSubdomainOrToken do
          Quaderno::Base.auth_token = '7h15154f4k370k3n'
          Quaderno::Tax.calculate(country: 'ES', postal_code: '08080')
        end
      end
    end

    should 'calculate tax' do
      VCR.use_cassette('calculate tax') do
        tax = Quaderno::Tax.calculate(country: 'ES', postal_code: '08080')
        assert_equal 'IVA', tax.name
        assert_equal 21.0, tax.rate

        tax = Quaderno::Tax.calculate(country: 'ES', postal_code: '35007')
        assert_equal 'IVA',tax.name
        assert tax.rate.zero?
      end
    end
  end
end