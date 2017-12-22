require 'helper'

describe Quaderno::Webhook do
  context 'A user with an authenticate token with webhooks' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all webhooks (populated db)' do
      VCR.use_cassette('all webhooks') do
      	webhook_1 = Quaderno::Webhook.create(url: 'http://google.com', events_types: ['invoice.created', 'invoice.updated'])
        webhook_2 = Quaderno::Webhook.create(url: 'http://quadernoapp.com', events_types: ['expense.created', 'expense.updated', 'contact.deleted'])
        webhooks = Quaderno::Webhook.all
        expect(webhooks.is_a? Array).to be true
        webhooks.each { |webhook| expect(webhook.is_a?(Quaderno::Webhook)).to be true }
        Quaderno::Webhook.delete webhook_1.id
        Quaderno::Webhook.delete webhook_2.id
      end
    end

    it 'should find a webhook' do
      VCR.use_cassette('found webhook') do
        webhook = Quaderno::Webhook.create(url: 'http://quadernoapp.com', events_types: ['invoice.created', 'expense.updated'])
        webhooks = Quaderno::Webhook.all
        expect(webhook.is_a?(Quaderno::Webhook)).to be true
        expect(webhook.id).to eq(webhooks.last.id)
        Quaderno::Webhook.delete webhook.id
      end
    end

    it 'should create a webhook' do
      VCR.use_cassette('new webhook') do
        webhook = Quaderno::Webhook.create(url: 'http://quadernoapp.com', events_types: ['invoice.created', 'expense.updated'])
        expect(webhook.is_a?(Quaderno::Webhook)).to be true
        expect(webhook.url).to eq 'http://quadernoapp.com'
        expect(webhook.events_types).to match_array ['invoice.created', 'expense.updated']
        Quaderno::Webhook.delete webhook.id
      end
    end

    it 'should update a webhook' do
      VCR.use_cassette('updated webhook') do
      	Quaderno::Webhook.create(url: 'http://quadernoapp.com', events_types: ['invoice.created', 'expense.updated'])
        webhooks = Quaderno::Webhook.all
        webhook = Quaderno::Webhook.update(webhooks.last.id, events_types: ['invoice.created', 'invoice.updated', 'contact.deleted'])
        expect(webhook.is_a?(Quaderno::Webhook)).to be true
        expect(webhook.events_types).to match_array ['invoice.created', 'invoice.updated', 'contact.deleted']
        Quaderno::Webhook.delete webhook.id
      end
    end

    it 'should delete a webhook' do
        VCR.use_cassette('deleted webhook') do
          webhook_1 = Quaderno::Webhook.create(url: 'http://google.com', events_types: ['invoice.created', 'expense.updated'])
          webhook_2 = Quaderno::Webhook.create(url: 'http://quadernoapp.com', events_types: ['invoice.created', 'expense.updated'])
          webhooks_before = Quaderno::Webhook.all
          webhook_id = webhooks_before.last.id
          Quaderno::Webhook.delete webhook_id
          webhooks_after = Quaderno::Webhook.all
          expect(webhook_id).not_to eq webhooks_after.last.id
          Quaderno::Webhook.delete webhooks_after.last.id
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