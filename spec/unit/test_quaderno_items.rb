require 'helper'

class TestQuadernoItem < Test::Unit::TestCase
  context 'A user with an authenticate token with items' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get exception if pass wrong arguments' do
      assert_raise ArgumentError do
        VCR.use_cassette('all items') do
          Quaderno::Item.all 1, 2, 3
        end
      end
      assert_raise ArgumentError do
        VCR.use_cassette('found item') do
          Quaderno::Item.find
        end
      end
    end

    it 'should get all items (populated db)' do
      VCR.use_cassette('all items') do
        items = Quaderno::Item.all
        assert_not_nil items
        assert_kind_of Array, items
        items.each do |item|
          assert_kind_of Quaderno::Item, item
        end
      end
    end

    it 'should find an item' do
      VCR.use_cassette('found item') do
        new_item = Quaderno::Item.create(code: Time.now.to_i.to_s, name: 'Test_Skynet', unit_cost: 21.00)
        item = Quaderno::Item.find new_item.id

        assert_kind_of Quaderno::Item, item
        assert_equal new_item.id, item.id
      end
    end

    it 'should create an item' do
      VCR.use_cassette('new item') do
        item = Quaderno::Item.create(code: '000000', name: 'Test_Skynet', unit_cost: 21.00)
        assert_kind_of Quaderno::Item, item
        assert_equal '000000', item.code
        assert_equal 'Test_Skynet', item.name
      end
    end

    it 'should update an item' do
      VCR.use_cassette('updated item') do
        new_item = Quaderno::Item.create(code: Time.now.to_i.to_s, name: 'Test_Skynet', unit_cost: 21.00)
        item = Quaderno::Item.update(new_item.id, name: 'Test_OCP')

        assert_kind_of Quaderno::Item, item
        assert_equal 'Test_OCP', item.name
      end
    end

    it 'should delete a item' do
      VCR.use_cassette('deleted item') do
        items_before = Quaderno::Item.all
        item_id = items_before.last.id
        Quaderno::Item.delete item_id
        items_after = Quaderno::Item.all
        assert_equal (items_before.length - items_after.length), 1
      end
    end

    it 'should know the rate limit' do
      VCR.use_cassette('rate limit') do
        rate_limit_info = Quaderno::Base.rate_limit_info
        assert_operator rate_limit_info[:remaining], :< ,2000
      end
    end
  end
end