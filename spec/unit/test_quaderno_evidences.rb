require 'helper'

class TestQuadernoEstimate < Test::Unit::TestCase
  context 'A user with an authenticate token with invoices' do
    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end

      VCR.use_cassette('evidence invoice') do
        @contacts = Quaderno::Contact.all
        @invoice = Quaderno::Invoice.create(contact_id: @contacts[0].id ,
                                           contact_name: @contacts[0].full_name,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt',
                                           payment_details: '',
                                           notes: '')
        assert_kind_of Quaderno::Invoice, @invoice
        assert_equal @contacts[0].id, @invoice.contact.id
        assert_equal 'Aircraft', @invoice.items[0].description
      end
    end

    should 'create an evidence' do
      VCR.use_cassette('new evidence') do
        evidence = Quaderno::Evidence.create(document_id: @invoice.id, billing_country: @contacts[0].country, bank_country: @contacts[0].country)
        assert_kind_of Quaderno::Evidence, evidence
        assert_equal @contacts[0].country, evidence.billing_country
      end
    end
  end
end