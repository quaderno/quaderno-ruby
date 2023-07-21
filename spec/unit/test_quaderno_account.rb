# frozen_string_literal: true

require 'helper'

describe Quaderno::Account do
  context 'using the default configuration with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all accounts (populated db)' do
      VCR.use_cassette('all accounts') do
        accounts = Quaderno::Account.all
        expect(accounts.empty?).to be false
        expect(accounts.is_a?(Array)).to be true
        accounts.each { |account| expect(account.is_a?(Quaderno::Account)).to be true }
      end
    end

    it 'should find an account' do
      VCR.use_cassette('found account') do
        accounts = Quaderno::Account.all
        account = Quaderno::Account.find accounts[2].id
        expect(account.is_a?(Quaderno::Account)).to be true
        expect(accounts[2].id).to eq account.id
      end
    end

    it 'should create an account' do
      VCR.use_cassette('new account') do
        account = Quaderno::Account.create(business_name: 'Test_Skynet', email: 'my_little@po.ny', local_tax_id: '11111111', country: 'ES')
        expect(account.is_a?(Quaderno::Account)).to be true
        expect(account.business_name).to eq 'Test_Skynet'
      end
    end

    it 'should update an account' do
      VCR.use_cassette('updated account') do
        accounts = Quaderno::Account.all
        account = Quaderno::Account.update(accounts[2].id, business_name: 'Test_OCP', email: 'dont@stop.believing')
        expect(account.is_a?(Quaderno::Account)).to be true
        expect(account.business_name).to eq 'Test_OCP'
      end
    end

    it 'should deactivate an account' do
      VCR.use_cassette('deactivate account') do
        new_account = Quaderno::Account.create(country: 'JP', business_name: 'Z, Mazinger Z', local_tax_id: '11111111', email: 'koji@kabuto.ftw')
        expect(new_account.state == 'active').to be true

        new_account = Quaderno::Account.deactivate new_account.id

        expect(new_account.state == 'hibernated').to be true
      end
    end

    it 'should activate an account' do
      VCR.use_cassette('activate account') do
        new_account = Quaderno::Account.create(country: 'JP', business_name: 'Z, Mazinger Z', local_tax_id: '11111111', email: 'koji@kabuto.ftw')
        new_account = Quaderno::Account.deactivate(new_account.id)
        expect(new_account.state == 'hibernated').to be true

        new_account = Quaderno::Account.activate new_account.id

        expect(new_account.state == 'active').to be true
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
      it 'should get all accounts (populated db)' do
        VCR.use_cassette('all accounts by authentication token') do
          accounts = Quaderno::Account.all(api_url: TEST_URL, auth_token: TEST_KEY)
          expect(accounts.is_a?(Array)).to be true
          accounts.each { |account| expect(account.is_a?(Quaderno::Account)).to be true }
        end
      end

      it 'should find an account' do
        VCR.use_cassette('found account by authentication token') do
          accounts = Quaderno::Account.all(api_url: TEST_URL, auth_token: TEST_KEY)
          account = Quaderno::Account.find accounts[2].id, api_url: TEST_URL, auth_token: TEST_KEY
          expect(account.is_a?(Quaderno::Account)).to be true
          expect(accounts[2].id).to eq account.id
        end
      end

      it 'should create an account' do
        VCR.use_cassette('new account by authentication token') do
          account = Quaderno::Account.create(business_name: 'Test_Skynet', local_tax_id: '11111111', email: "#{Time.now.to_i}my_little@po.ny", country: 'ES', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(account.is_a?(Quaderno::Account)).to be true
          expect(account.business_name).to eq 'Test_Skynet'
        end
      end

      it 'should update an account' do
        VCR.use_cassette('updated account by authentication token') do
          accounts = Quaderno::Account.all(api_url: TEST_URL, auth_token: TEST_KEY)
          account = Quaderno::Account.update(accounts[2].id, business_name: 'Test_OCP', local_tax_id: '11111111', email: 'dont@stop.believing', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(account.is_a?(Quaderno::Account)).to be true
          expect(account.business_name).to eq 'Test_OCP'
        end
      end

      it 'should deactivate an account' do
        VCR.use_cassette('deactivate account by authentication token') do
          new_account = Quaderno::Account.create(country: 'JP', business_name: 'Z, Mazinger Z', local_tax_id: '11111111', email: 'koji@kabuto.ftw', api_url: TEST_URL, auth_token: TEST_KEY)
          expect(new_account.state == 'active').to be true

          new_account = Quaderno::Account.deactivate new_account.id, api_url: TEST_URL, auth_token: TEST_KEY

          expect(new_account.state == 'hibernated').to be true
        end
      end

      it 'should activate an account' do
        VCR.use_cassette('activate account by authentication token') do
          new_account = Quaderno::Account.create(country: 'JP', business_name: 'Z, Mazinger Z', local_tax_id: '11111111', email: "#{Time.now.to_i}_koji@kabuto.ftw", api_url: TEST_URL, auth_token: TEST_KEY)
          new_account = Quaderno::Account.deactivate(new_account.id, api_url: TEST_URL, auth_token: TEST_KEY)
          expect(new_account.state == 'hibernated').to be true

          new_account = Quaderno::Account.activate new_account.id, api_url: TEST_URL, auth_token: TEST_KEY

          expect(new_account.state == 'active').to be true
        end
      end
    end
  end
end
