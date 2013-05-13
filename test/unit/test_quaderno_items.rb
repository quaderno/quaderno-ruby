require 'helper'

class TestQuadernoItem < Test::Unit::TestCase
  context "A user with an authenticate token with items" do

    setup do
      Quaderno::Base.configure do |config|
      	config.auth_token = 'zDQ91a8GGsXf4Wzon5jY'
      	config.subdomain = 'recrea'
      end    
    end

    should "get exception if pass wrong arguments" do
      assert_raise ArgumentError do 
        VCR.use_cassette('all items') do
          Quaderno::Item.all 1
        end
      end
      assert_raise ArgumentError do 
        VCR.use_cassette('found item') do
          Quaderno::Item.find
        end
      end
    end

    should "get all items (populated db)" do
      VCR.use_cassette('all items') do
        items = Quaderno::Item.all
        assert_not_nil items
        assert_kind_of Array, items
        items.each do |item|
          assert_kind_of Quaderno::Item, item
        end
      end
    end

    should "find an item" do
      VCR.use_cassette('found item') do
        items = Quaderno::Item.all
        item = Quaderno::Item.find items[2].id
        assert_kind_of Quaderno::Item, item
        assert_equal items[2].id, item.id
      end
    end
    
    should "create an item" do
      VCR.use_cassette('new item') do
        item = Quaderno::Item.create(code: '000000', name: 'Test_Skynet', unit_cost: 21.00)
        assert_kind_of Quaderno::Item, item
        assert_equal '000000', item.code
        assert_equal 'Test_Skynet', item.name
      end
    end
    
    should "update an item" do
      VCR.use_cassette('updated item') do
        items = Quaderno::Item.all
        item = Quaderno::Item.update(items[2].id, name: 'Test_OCP')
        assert_kind_of Quaderno::Item, item
        assert_equal 'Test_OCP', item.name
      end
    end
    
    should "delete a item" do
        VCR.use_cassette('deleted item') do
          items_before = Quaderno::Item.all
          item_id = items_before[10].id
          Quaderno::Item.delete item_id
          items_after = Quaderno::Item.all
          assert_not_equal items_after[10].id, item_id
        end
    end
    
    should "know the rate limit" do
      VCR.use_cassette('rate limit') do
        rate_limit_info = Quaderno::Base.rate_limit_info
        assert_equal 1000, rate_limit_info[:limit]
        assert_operator rate_limit_info[:remaining], :< ,1000     
      end
    end
  end
end