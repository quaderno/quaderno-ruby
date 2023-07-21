# frozen_string_literal: true

require 'helper'

describe Quaderno::TaxRate do
  let(:france_id) { 11 }
  let(:italy_id) { 68 }
  let(:swiss_id) { 86 }

  context 'using the default configuration with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all tax rates (populated db)' do
      VCR.use_cassette('all tax rates') do
        tax_rates = Quaderno::TaxRate.all
        expect(tax_rates.empty?).to be false
        expect(tax_rates.is_a?(Array)).to be true
        tax_rates.each { |tax_rate| expect(tax_rate.is_a?(Quaderno::TaxRate)).to be true }
      end
    end

    it 'should not find a default tax rate' do
      VCR.use_cassette('find default tax rate') do
        tax_rates = Quaderno::TaxRate.all
        expect(tax_rates[2].type).to eq 'default'
        expect { Quaderno::TaxRate.find tax_rates[2].id }.to raise_error(Quaderno::Exceptions::InvalidSubdomainOrToken)
      end
    end

    it 'should find a custom tax rate' do
      VCR.use_cassette('found custom tax rate') do
        tax_rate = Quaderno::TaxRate.create(name: 'Custom Italian Tax', value: 50, jurisdiction_id: italy_id)
        expect(tax_rate.type).to eq 'custom'
        found_tax_rate = Quaderno::TaxRate.find tax_rate.id
        expect(found_tax_rate.is_a?(Quaderno::TaxRate)).to be true
        expect(found_tax_rate.id).to eq tax_rate.id
        expect(found_tax_rate.value).to eq tax_rate.value
      end
    end

    it 'should create a tax rate' do
      VCR.use_cassette('new tax_rate') do
        tax_rate = Quaderno::TaxRate.create(name: 'Custom Swiss Tax', value: 11.11, jurisdiction_id: swiss_id)
        expect(tax_rate.is_a?(Quaderno::TaxRate)).to be true
        expect(tax_rate.jurisdiction['country']).to eq 'CH'
        expect(tax_rate.value).to eq 11.11
      end
    end

    it 'should not update a default tax rate' do
      VCR.use_cassette('update default tax rate') do
        tax_rates = Quaderno::TaxRate.all
        expect(tax_rates[0].type).to eq 'default'
        expect { Quaderno::TaxRate.update(tax_rates[0].id, value: 32) }.to raise_error(Quaderno::Exceptions::InvalidSubdomainOrToken)
      end
    end

    it 'should update a custom tax rate' do
      VCR.use_cassette('updated custom tax rate') do
        tax_rate = Quaderno::TaxRate.create(name: 'Custom Swiss Tax', value: 12.12, jurisdiction_id: swiss_id, valid_from: '2018-01-03')
        expect(tax_rate.type).to eq 'custom'

        tax_rate = Quaderno::TaxRate.update(tax_rate.id, value: 23.0, valid_until: '2023-04-01')
        expect(tax_rate.is_a?(Quaderno::TaxRate)).to be true
        expect(tax_rate.valid_until).to eq '2023-04-01'
        expect(tax_rate.value).to eq 23.0
      end
    end

    it 'should not delete a default tax rate' do
      VCR.use_cassette('delete default tax rate') do
        tax_rates = Quaderno::TaxRate.all
        expect(tax_rates[0].type).to eq 'default'
        expect { Quaderno::TaxRate.delete(tax_rates[0].id) }.to raise_error(Quaderno::Exceptions::InvalidSubdomainOrToken)
      end
    end

    it 'should delete a custom tax rate' do
      VCR.use_cassette('deleted custom tax rate') do
        custom_tax_rate = Quaderno::TaxRate.create(name: 'Custom Swiss Tax', value: 11.11, jurisdiction_id: swiss_id)
        tax_rates_before = Quaderno::TaxRate.all.map(&:id)
        expect(tax_rates_before.include?(custom_tax_rate.id)).to be true

        Quaderno::TaxRate.delete custom_tax_rate.id

        tax_rates_after = Quaderno::TaxRate.all
        expect(tax_rates_after.include?(custom_tax_rate.id)).to be false
      end
    end

    it 'should calculate a tax rate' do
      VCR.use_cassette('validate tax rate') do
        result = Quaderno::TaxRate.calculate(from_country: 'FR', to_country: 'FR', tax_code: 'standard')
        expect(result.country).to eq 'FR'
        expect(result.name).to eq 'TVA'
        expect(result.rate).to eq 20.0
        expect(result.tax_code).to eq 'standard'
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
