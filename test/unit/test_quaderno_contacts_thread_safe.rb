require 'helper'

class TestQuadernoContactThreadSafe < Test::Unit::TestCase
  context 'using the thread-safe configuration' do
    context 'with an authentication token' do
      should 'get all contacts (populated db)' do
        VCR.use_cassette('all contacts by authentication token') do
          puts Quaderno::Base.url
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          assert_not_nil contacts
          assert_kind_of Array, contacts
          contacts.each { |contact| assert_kind_of Quaderno::Contact, contact }
        end
      end

      should 'find a contact' do
        VCR.use_cassette('found contact by authentication token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          contact = Quaderno::Contact.find contacts[2].id, api_url: TEST_URL, auth_token: TEST_KEY
          assert_kind_of Quaderno::Contact, contact
          assert_equal contacts[2].id, contact.id
        end
      end

      should 'create a contact' do
        VCR.use_cassette('new contact by authentication token') do
          contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny', api_url: TEST_URL, auth_token: TEST_KEY)
          assert_kind_of Quaderno::Contact, contact
          assert_equal 'company', contact.kind
          assert_equal 'Test_Skynet', contact.full_name
        end
      end

      should 'update a contact' do
        VCR.use_cassette('updated contact by authentication token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
          contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing', api_url: TEST_URL, auth_token: TEST_KEY)
          assert_kind_of Quaderno::Contact, contact
          assert_equal 'Test_OCP', contact.first_name || contact.full_name
        end
      end

      should 'delete a contact' do
          VCR.use_cassette('deleted contact by authentication token') do
            new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw', api_url: TEST_URL, auth_token: TEST_KEY)
            contacts_before = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
            contact_id = contacts_before.last.id
            Quaderno::Contact.delete contact_id, api_url: TEST_URL, auth_token: TEST_KEY
            contacts_after = Quaderno::Contact.all(api_url: TEST_URL, auth_token: TEST_KEY)
            assert_not_equal contacts_after.last.id, contact_id
          end
      end
    end

    context 'with an OAuth 2.0 access token' do
      should 'get all contacts (populated db)' do
        VCR.use_cassette('all contacts by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          assert_not_nil contacts
          assert_kind_of Array, contacts
          contacts.each { |contact| assert_kind_of Quaderno::Contact, contact }
        end
      end

      should 'find a contact' do
        VCR.use_cassette('found contact by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact = Quaderno::Contact.find contacts[2].id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
          assert_kind_of Quaderno::Contact, contact
          assert_equal contacts[2].id, contact.id
        end
      end

      should 'create a contact' do
        VCR.use_cassette('new contact by access token') do
          contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          assert_kind_of Quaderno::Contact, contact
          assert_equal 'company', contact.kind
          assert_equal 'Test_Skynet', contact.full_name
        end
      end

      should 'update a contact' do
        VCR.use_cassette('updated contact by access token') do
          contacts = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          assert_kind_of Quaderno::Contact, contact
          assert_equal 'Test_OCP', contact.first_name || contact.full_name
        end
      end

      should 'delete a contact' do
        VCR.use_cassette('deleted contact by access token') do
          new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw', api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contacts_before = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          contact_id = contacts_before.last.id
          Quaderno::Contact.delete contact_id, api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN
          contacts_after = Quaderno::Contact.all(api_url: TEST_URL, access_token: TEST_OAUTH_ACCESS_TOKEN)
          assert_not_equal contacts_after.last.id, contact_id
        end
      end
    end
  end
end