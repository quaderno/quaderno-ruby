require 'helper'

class TestQuadernoContact < Test::Unit::TestCase
  context "A user with an authenticate token" do
    setup do
      @auth_token = 'Lt4Q6zAvGzmbN7dsbcmA'
      @subdomain = 'assur-219'
      Quaderno::Base.init(@auth_token, @subdomain)
      assert_equal true, true #REMEMBER TODO
    end

    should "get exception if pass wrong arguments" do
      assert_raise ArgumentError do 
        Quaderno::Contact.all 1
      end
      assert_raise ArgumentError do 
        Quaderno::Contact.find
      end
    end

    should "get all contacts (populated db)" do
      VCR.use_cassette('all contacts') do
        contacts = Quaderno::Contact.all
        assert_not_nil contacts
        assert_kind_of Array, contacts
        assert_kind_of Quaderno::Contact, contacts[0]
      end
    end

    should "find a contact" do
      VCR.use_cassette('found contact') do
        contact = Quaderno::Contact.find '5059bdbf2f412e0901000024'
        assert_kind_of Quaderno::Contact, contact
        assert_equal '5059bdbf2f412e0901000024', contact.id
      end
    end
    
    should "create a contact" do
      VCR.use_cassette('new contact') do
        contact = Quaderno::Contact.create(kind: 'company', first_name: 'Test_Skynet')
        assert_kind_of Quaderno::Contact, contact
        assert_equal 'Test_Skynet', contact.first_name
        assert_equal 'company', contact.kind
      end
    end
    
    should "update a contact" do
      VCR.use_cassette('updated contact') do
        contact = Quaderno::Contact.update('506c2b452f412e024500002a', first_name: 'Test_OCP')
        assert_kind_of Quaderno::Contact, contact
        assert_equal 'Test_OCP', contact.first_name
      end
    end
    
    should "know the rate limit" do
      rate_limit_info = Quaderno::Base.rate_limit_info
      assert_equal 100, rate_limit_info[:limit]
      assert_operator rate_limit_info[:remaining], :< ,100     
    end
  end
end