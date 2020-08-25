require 'helper'

describe Quaderno::CheckoutSession do
  context 'A user with an authenticate token with checkout sessions' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end

      VCR.use_cassette('new item') do
        @product = Quaderno::Item.create(code: '000000', name: 'Test_Skynet', unit_cost: 21.00)
      end
    end

    after(:each) do
      VCR.use_cassette('deleted item') do
        Quaderno::Item.delete @product.id
      end
    end

    it 'should get all checkout sessions (populated db)' do
      VCR.use_cassette('all checkout sessions') do
        checkout_session_1 = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        checkout_session_2 = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )

        checkout_sessions = Quaderno::CheckoutSession.all
        expect(checkout_sessions.is_a? Array).to be true
        checkout_sessions.each { |checkout_session| expect(checkout_session.is_a?(Quaderno::CheckoutSession)).to be true }
        Quaderno::CheckoutSession.delete checkout_session_1.id
        Quaderno::CheckoutSession.delete checkout_session_2.id
      end
    end

    it 'should find a checkout session' do
      VCR.use_cassette('found checkout session') do
        created_checkout_session = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        checkout_session = Quaderno::CheckoutSession.find(created_checkout_session.id)
        expect(checkout_session.is_a?(Quaderno::CheckoutSession)).to be true
        expect(checkout_session.id).to eq(created_checkout_session.id)
        Quaderno::CheckoutSession.delete checkout_session.id
      end
    end

    it 'should create a checkout session' do
      VCR.use_cassette('new checkout session') do
        checkout_session = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        expect(checkout_session.is_a?(Quaderno::CheckoutSession)).to be true
        expect(checkout_session.success_url).to eq 'http://example.com/success'
        expect(checkout_session.cancel_url).to eq 'http://example.com/cancel'
        expect(checkout_session.status).to eq 'pending'
        Quaderno::CheckoutSession.delete checkout_session.id
      end
    end

    it 'should update a checkout session' do
      VCR.use_cassette('updated checkout session') do
        checkout_session = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        checkout_sessions = Quaderno::CheckoutSession.all
        checkout_session = Quaderno::CheckoutSession.update(checkout_sessions.last.id, cancel_url: 'http://example.com/unsuccessful')
        expect(checkout_session.is_a?(Quaderno::CheckoutSession)).to be true
        expect(checkout_session.cancel_url).to eq('http://example.com/unsuccessful')
        Quaderno::CheckoutSession.delete checkout_session.id
      end
    end

    it 'should delete a checkout session' do
      VCR.use_cassette('deleted checkout session') do
        checkout_session_1 = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        checkout_session_2 = Quaderno::CheckoutSession.create(
          billing_details_collection: 'auto', 
          cancel_url: 'http://example.com/cancel',
          success_url: 'http://example.com/success',
          coupon_collection: true,
          items: [
            { product: @product.code}
          ]
        )
        checkout_sessions_before = Quaderno::CheckoutSession.all
        checkout_session_id = checkout_sessions_before.last.id
        Quaderno::CheckoutSession.delete checkout_session_id
        checkout_sessions_after = Quaderno::CheckoutSession.all
        expect(checkout_session_id).not_to eq checkout_sessions_after.last.id
        Quaderno::CheckoutSession.delete checkout_sessions_after.last.id
      end
    end

    it 'should know the rate limit' do
      VCR.use_cassette('rate limit') do
        result = Quaderno::Base.rate_limit_info
        expect(result.rate_limit_info[:remaining] < 2000).to be true
      end
    end
  end
end
