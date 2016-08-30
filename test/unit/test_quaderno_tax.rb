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
      VCR.use_cassette('validate valid VAT number') do
        vat_number_valid = Quaderno::Tax.validate_vat_number('IE', 'IE6388047V')
        assert vat_number_valid
      end

       VCR.use_cassette('validate invalid VAT number') do
        vat_number_valid = Quaderno::Tax.validate_vat_number('IE', 'IE6388047X')
        assert !vat_number_valid
      end
    end

    should 'validate VAT number' do
      VCR.use_cassette('calculate tax') do
      end
    end
  end
end