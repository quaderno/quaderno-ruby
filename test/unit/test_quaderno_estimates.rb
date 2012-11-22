require 'helper'

class TestQuadernoEstimate < Test::Unit::TestCase
  context 'A user with an authenticate token with estimates' do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = 'xiZvifX5hwsxAiymYPk2'
        config.subdomain = 'recrea'
      end
    end

    should 'get exception if pass wrong arguments' do
      assert_raise ArgumentError do 
        VCR.use_cassette('all estimates') do
          Quaderno::Estimate.all 1
        end
      end
      assert_raise ArgumentError do 
        VCR.use_cassette('found estimate') do
          Quaderno::Estimate.find
        end
      end
    end

    should 'get all estimates (populated db)' do
      VCR.use_cassette('all estimates') do
        estimates = Quaderno::Estimate.all
        assert_not_nil estimates
        assert_kind_of Array, estimates
        estimates.each do |estimate|
          assert_kind_of Quaderno::Estimate, estimate
        end
      end
    end

    should 'find an estimate' do
      VCR.use_cassette('found estimate') do
        estimates = Quaderno::Estimate.all
        estimate = Quaderno::Estimate.find estimates.first.id
        assert_kind_of Quaderno::Estimate, estimate
        assert_equal estimates.first.id, estimate.id
      end
    end
    
    should 'create an estimate' do
      VCR.use_cassette('new estimate') do
        contacts = Quaderno::Contact.all
        estimate = Quaderno::Estimate.create(contact_id: contacts.first.id ,
                                            contact_name: contacts.first.full_name, 
                                            currency: 'EUR', 
                                            items: [
                                              { 
                                                description: 'Aircraft', 
                                                quantity: '1.0', 
                                                unit_price: '0.0' 
                                              }
                                            ],
                                            tags: 'tnt', payment_details: '', 
                                            notes: '')
        assert_kind_of Quaderno::Estimate, estimate
        assert_equal contacts.first.id, estimate.contact.id
        assert_equal 'Aircraft', estimate.items.first.description
      end
    end
    
    should 'update an estimate' do
      VCR.use_cassette('updated estimate') do
        estimates = Quaderno::Estimate.all
        estimate = Quaderno::Estimate.update(estimates.first.id, payment_details: 'Show me the moneeeeeeeyy!!!!')
        assert_kind_of Quaderno::Estimate, estimate
        assert_equal 'Show me the moneeeeeeeyy!!!!', estimate.payment_details
      end
    end
    
    should 'delete an estimate' do
        VCR.use_cassette('deleted estimate') do
          estimates = Quaderno::Estimate.all
          estimate_id = estimates.first.id
          Quaderno::Estimate.delete estimate_id
          estimates = Quaderno::Estimate.all
          assert_not_equal estimates.first.id, estimate_id
        end
    end
    
    should 'deliver an estimate' do
      VCR.use_cassette('delivered estimate') do
        estimates = Quaderno::Estimate.all
        rate_limit_before = Quaderno::Base.rate_limit_info
        begin
          rate_limit_after = estimates.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmpty
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end
        assert_equal rate_limit_before[:remaining]-1, rate_limit_after[:remaining]
      end
    end
  end
end