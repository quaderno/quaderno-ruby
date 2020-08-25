require 'helper'

describe Quaderno::Contact do

  context 'using the default configuration with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all contacts (populated db)' do
      VCR.use_cassette('all contacts') do
        contacts = Quaderno::Contact.all
        expect(contacts.empty?).to be false
        expect(contacts.is_a? Array).to be true
        contacts.each { |contact| expect(contact.is_a?(Quaderno::Contact)).to be true }
      end
    end

    it 'should find a contact' do
      VCR.use_cassette('found contact') do
        contacts = Quaderno::Contact.all
        contact = Quaderno::Contact.find contacts[2].id
        expect(contact.is_a?(Quaderno::Contact)).to be true
        expect(contacts[2].id).to eq contact.id
      end
    end

    it 'should create a contact' do
      VCR.use_cassette('new contact') do
        contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny')
        expect(contact.is_a?(Quaderno::Contact)).to be true
        expect(contact.kind).to eq 'company'
        expect(contact.full_name).to eq 'Test_Skynet'
      end
    end

    it 'should update a contact' do
      VCR.use_cassette('updated contact') do
        contacts = Quaderno::Contact.all
        contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing')
        expect(contact.is_a?(Quaderno::Contact)).to be true
        expect(contact.first_name || contact.full_name).to eq 'Test_OCP'
      end
    end

    it 'should delete a contact' do
        VCR.use_cassette('deleted contact') do
          new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw')
          contacts_before = Quaderno::Contact.all
          contact_id = contacts_before.last.id
          Quaderno::Contact.delete contact_id
          contacts_after = Quaderno::Contact.all
          expect(contacts_after.last.id).not_to eq contact_id
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
      it 'should get all contacts (populated db)' do
        VCR.use_cassette('all contacts by authentication token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          expect(contacts.is_a? Array).to be true
          contacts.each { |contact| expect(contact.is_a?(Quaderno::Contact)).to be true }
        end
      end

      it 'should find a contact' do
        VCR.use_cassette('found contact by authentication token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          contact = Quaderno::Contact.find contacts[2].id, api_url: TEST_URL, auth_token: TEST_KEY
          expect(contact.is_a?(Quaderno::Contact)).to be true
          expect(contacts[2].id).to eq contact.id
        end
      end

      it 'should create a contact' do
        VCR.use_cassette('new contact by authentication token') do
          contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(contact.is_a?(Quaderno::Contact)).to be true
          expect(contact.kind).to eq 'company'
          expect(contact.full_name).to eq 'Test_Skynet'
        end
      end

      it 'should update a contact' do
        VCR.use_cassette('updated contact by authentication token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(contact.is_a?(Quaderno::Contact)).to be true
          expect(contact.first_name || contact.full_name).to eq 'Test_OCP'
        end
      end

      it 'should delete a contact' do
        VCR.use_cassette('deleted contact by authentication token') do
          new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw', api_url: TEST_URL, auth_token: TEST_KEY)
          contacts_before = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          contact_id = contacts_before.last.id
          Quaderno::Contact.delete contact_id, api_url: TEST_URL, auth_token: TEST_KEY
          contacts_after = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          expect(contacts_after.last.id).not_to eq contact_id
        end
      end
    end

    context 'with an OAuth 2.0 access token' do
      it 'should get all contacts (populated db)' do
        VCR.use_cassette('all contacts by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(contacts.is_a? Array).to be true
          contacts.each { |contact| expect(contact.is_a?(Quaderno::Contact)).to be true }
        end
      end

      it 'should find a contact' do
        VCR.use_cassette('found contact by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact = Quaderno::Contact.find contacts[2].id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
          expect(contact.is_a? Quaderno::Contact).to be true
          expect(contacts[2].id).to eq contact.id
        end
      end

      it 'should create a contact' do
        VCR.use_cassette('new contact by access token') do
          contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(contact.is_a? Quaderno::Contact).to be true
          expect(contact.kind).to eq 'company'
          expect(contact.full_name).to eq 'Test_Skynet'
        end
      end

      it 'should update a contact' do
        VCR.use_cassette('updated contact by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(contact.is_a?(Quaderno::Contact)).to be true
          expect(contact.first_name || contact.full_name).to eq 'Test_OCP'
        end
      end

      it 'should delete a contact' do
        VCR.use_cassette('deleted contact by access token') do
          new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contacts_before = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact_id = contacts_before.last.id
          Quaderno::Contact.delete contact_id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
          contacts_after = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          expect(contacts_after.last.id).not_to eq contact_id
        end
      end
    end
  end
end