require 'helper'

describe Quaderno::Item do
  context 'A user with an authenticate token with items' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all items (populated db)' do
      VCR.use_cassette('all items') do
        items = Quaderno::Item.all
        expect(items.is_a? Array).to be true
        items.each { |item| expect(item.is_a? Quaderno::Item).to be true }
      end
    end

    it 'should find an item' do
      VCR.use_cassette('found item') do
        new_item = Quaderno::Item.create(code: Time.now.to_i.to_s, name: 'Test_Skynet', unit_cost: 21.00)
        item = Quaderno::Item.find new_item.id

        expect(item.is_a? Quaderno::Item).to be true
        expect(item.id).to eq(new_item.id)
      end
    end

    it 'should create an item' do
      VCR.use_cassette('new item') do
        item = Quaderno::Item.create(code: '000000', name: 'Test_Skynet', unit_cost: 21.00)
        expect(item.is_a? Quaderno::Item).to be true
        expect(item.code).to eq '000000'
        expect(item.name).to eq 'Test_Skynet'
      end
    end

    it 'should update an item' do
      VCR.use_cassette('updated item') do
        new_item = Quaderno::Item.create(code: Time.now.to_i.to_s, name: 'Test_Skynet', unit_cost: 21.00)
        item = Quaderno::Item.update(new_item.id, name: 'Test_OCP')

        expect(item.is_a? Quaderno::Item).to be true
        expect(item.name).to eq 'Test_OCP'
      end
    end

    it 'should delete a item' do
      VCR.use_cassette('deleted item') do
        items_before = Quaderno::Item.all
        item_id = items_before.last.id
        Quaderno::Item.delete item_id
        items_after = Quaderno::Item.all
        expect(items_before.length - items_after.length).to eq 1
      end
    end

    it 'should know the rate limit' do
      VCR.use_cassette('rate limit') do
        rate_limit_info = Quaderno::Base.rate_limit_info
        expect(rate_limit_info[:remaining] < 2000).to be true
      end
    end
  end
end