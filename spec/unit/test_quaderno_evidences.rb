require 'helper'

describe Quaderno::Evidence do
  context 'A user with an authenticate token with invoices' do
    before(:each) do
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
        expect(@invoice.is_a? Quaderno::Invoice).to be true
        expect(@invoice.contact.id).to eq @contacts[0].id
        expect(@invoice.items[0].description).to eq 'Aircraft'
      end
    end

    it 'should create an evidence' do
      VCR.use_cassette('new evidence') do
        evidence = Quaderno::Evidence.create(document_id: @invoice.id, billing_country: @contacts[0].country, bank_country: @contacts[0].country)
        expect(evidence.is_a? Quaderno::Evidence).to be true
        expect(evidence.billing_country).to eq @contacts[0].country
      end
    end
  end
end