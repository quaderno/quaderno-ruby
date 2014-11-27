require 'helper'

class TestQuadernoTax < Test::Unit::TestCase
  context "A user with an authenticate token with webhooks" do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = 'fMLf9TGWrRqNxJ4chcVi'
        config.subdomain = 'assur-744'
      end   
    end

    should "raise exception if pass wrong arguments" do
      assert_raise ArgumentError do
        Quaderno::Tax.calculate 1, 2, 3
      end
    end

    should "raise exception if token is wrong" do
      VCR.use_cassette('wrong token') do
        assert_raise Quaderno::Exceptions::InvalidSubdomainOrToken do
          Quaderno::Base.auth_token = '7h15154f4k370k3n'
          Quaderno::Tax.calculate(country: 'ES', postal_code: '08080')
        end
      end
    end

    should "calculate tax" do
      VCR.use_cassette('calculate tax') do
        tax = Quaderno::Tax.calculate(country: 'ES', postal_code: '08080')
        assert_equal 'VAT', tax.name
        assert_equal 21.0, tax.rate

        tax = Quaderno::Tax.calculate(country: 'ES', postal_code: '35007')
        assert tax.name.nil?
        assert tax.rate.zero?
        assert_equal 'VAT reverse charged', tax.notes 
      end
    end
  end
end