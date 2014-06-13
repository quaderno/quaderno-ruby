require 'helper'

class TestQuadernoContact < Test::Unit::TestCase
  context "A user with an authenticate token with contacts" do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = 'kAppsMggGcw8psUwdZBV'
        config.subdomain = 'ninive-688'
        config.environment = :sandbox
      end
    end

    should "get exception if pass wrong arguments" do
      assert_raise ArgumentError do 
        VCR.use_cassette('all contacts') do
          Quaderno::Contact.all 1, 2, 3
        end
      end
      assert_raise ArgumentError do 
        VCR.use_cassette('found contact') do
          Quaderno::Contact.find
        end
      end
    end

    should "get all contacts (populated db)" do
      VCR.use_cassette('all contacts') do
        contacts = Quaderno::Contact.all
        assert_not_nil contacts
        assert_kind_of Array, contacts
        contacts.each do |contact|
          assert_kind_of Quaderno::Contact, contact
        end
      end
    end

    should "find a contact" do
      VCR.use_cassette('found contact') do
        contacts = Quaderno::Contact.all
        contact = Quaderno::Contact.find contacts[2].id
        assert_kind_of Quaderno::Contact, contact
        assert_equal contacts[2].id, contact.id
      end
    end
    
    should "create a contact" do
      VCR.use_cassette('new contact') do
        contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet', email: 'my_little@po.ny')
        assert_kind_of Quaderno::Contact, contact
        assert_equal 'company', contact.kind
        assert_equal 'Test_Skynet', contact.full_name
      end
    end
    
    should "update a contact" do
      VCR.use_cassette('updated contact') do
        contacts = Quaderno::Contact.all
        contact = Quaderno::Contact.update(contacts[2].id, first_name: 'Test_OCP', email: 'dont@stop.believing')
        assert_kind_of Quaderno::Contact, contact
        assert_equal 'Test_OCP', contact.first_name || contact.full_name
      end
    end
    
    should "delete a contact" do
        VCR.use_cassette('deleted contact') do
          new_contact = Quaderno::Contact.create(kind: 'company', first_name: 'Z, Mazinger Z', email: 'koji@kabuto.ftw')
          contacts_before = Quaderno::Contact.all
          contact_id = contacts_before.last.id
          Quaderno::Contact.delete contact_id
          contacts_after = Quaderno::Contact.all
          assert_not_equal contacts_after.last.id, contact_id
        end
    end
    
    should "know the rate limit" do
      VCR.use_cassette('rate limit') do
        rate_limit_info = Quaderno::Base.rate_limit_info
        assert_equal 2000, rate_limit_info[:limit]
        assert_operator rate_limit_info[:remaining], :< ,2000     
      end
    end
  end
end