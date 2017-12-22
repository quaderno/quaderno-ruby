require 'helper'

describe Quaderno::Estimate do
  context 'A user with an authenticate token with estimates' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all estimates (populated db)' do
      VCR.use_cassette('all estimates') do
        estimates = Quaderno::Estimate.all
        expect(estimates.is_a? Array).to be true
        estimates.each { |estimate| expect(estimate.is_a? Quaderno::Estimate).to be true }
      end
    end

    it 'should find an estimate' do
      VCR.use_cassette('found estimate') do
        estimates = Quaderno::Estimate.all
        estimate = Quaderno::Estimate.find estimates.first.id
        expect(estimate.is_a? Quaderno::Estimate).to be true
        expect(estimates.first.id).to eq estimate.id
      end
    end

    it 'should create an estimate' do
      VCR.use_cassette('new estimate') do
        contacts = Quaderno::Contact.all
        estimate = Quaderno::Estimate.create(contact_id: contacts.first.id ,
                                            number: 'test number 42',
                                            contact_name: contacts.first.full_name,
                                            currency: 'EUR',
                                            items_attributes: [
                                              {
                                                description: 'Aircraft',
                                                quantity: '1.0',
                                                unit_price: '0.0'
                                              }
                                            ],
                                            tags: 'tnt', payment_details: '',
                                            notes: '')
        expect(estimate.is_a? Quaderno::Estimate).to be true
        expect(contacts.first.id).to eq estimate.contact.id
        expect(estimate.items.first.description).to eq 'Aircraft'
        Quaderno::Estimate.delete(estimate.id)
      end
    end

    it 'should update an estimate' do
      VCR.use_cassette('updated estimate') do
        contacts = Quaderno::Contact.all
        estimate = Quaderno::Estimate.create(contact_id: contacts.first.id,
                                            number: 'test number 4400',
                                            contact_name: contacts.first.full_name,
                                            currency: 'EUR',
                                            items_attributes: [
                                              {
                                                description: 'Aircraft',
                                                quantity: '1.0',
                                                unit_price: '0.0'
                                              }
                                            ],
                                            tags: 'tnt', payment_details: '',
                                            notes: '')
        estimate = Quaderno::Estimate.update(estimate.id, payment_details: 'Show me the moneeeeeeeyy!!!!')
        expect(estimate.is_a? Quaderno::Estimate).to be true
        expect(estimate.payment_details).to eq 'Show me the moneeeeeeeyy!!!!'
        Quaderno::Estimate.delete(estimate.id)
      end
    end

    it 'should delete an estimate' do
        VCR.use_cassette('deleted estimate') do
          contacts = Quaderno::Contact.all
          estimate = Quaderno::Estimate.create(contact_id: contacts.first.id,
                                              number: 'test number 4400',
                                              contact_name: contacts.first.full_name,
                                              currency: 'EUR',
                                              items_attributes: [
                                                {
                                                  description: 'Aircraft',
                                                  quantity: '1.0',
                                                  unit_price: '0.0'
                                                }
                                              ],
                                              tags: 'tnt', payment_details: '',
                                              notes: '')
          Quaderno::Estimate.delete estimate.id
          estimates = Quaderno::Estimate.all
          expect(estimates.first.id).not_to eq estimate.id
        end
    end

    it 'should deliver an estimate' do
      VCR.use_cassette('delivered estimate') do
        estimates = Quaderno::Estimate.all
        rate_limit_before = Quaderno::Base.rate_limit_info
        begin
          rate_limit_after = estimates.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end

        expect(rate_limit_after[:remaining]).to eq(rate_limit_before[:remaining] - 1)
      end
    end

    it 'should override version' do
      Quaderno::Base.api_version = OLDEST_SUPPORTED_API_VERSION

      VCR.use_cassette('create estimate on downgraded API') do
        contacts = Quaderno::Contact.all
        estimate = Quaderno::Estimate.create(contact_id: contacts.first.id ,
                                            number: 'test number 42',
                                            contact_name: contacts.first.full_name,
                                            currency: 'EUR',
                                            items_attributes: [
                                              {
                                                description: 'Aircraft',
                                                quantity: '1.0',
                                                unit_price: '0.0'
                                              }
                                            ],
                                            tags: 'tnt', payment_details: '',
                                            notes: '')
        expect(estimate.is_a? Quaderno::Estimate).to be true
        expect(estimate.total_cents.nil?).to be true
        expect(!estimate.total.nil?).to be true
        expect(contacts.first.id).to eq estimate.contact.id
        expect(estimate.items.first.description).to eq 'Aircraft'
        Quaderno::Estimate.delete(estimate.id)
      end
    end
  end
end