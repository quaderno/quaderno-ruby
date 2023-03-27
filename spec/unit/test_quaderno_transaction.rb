# frozen_string_literal: true

require 'helper'

describe Quaderno::Transaction do
  context 'A user with an authentication token' do
    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should create a sale transaction' do
      sale_params = {
        type: 'sale', customer: { first_name: 'John', last_name: 'Smith', email: 'an_email@example.com' },
        evidence: { billing_country: 'US', ip_address: '255.255.255.255', bank_country: 'US' },
        currency: 'USD',
        items: [
          {
            description: 'Awesome ebook', quantity: 1, amount: 19,
            tax: {
              city: nil, country: 'US', county: nil, currency: 'USD', name: nil, notes: nil,
              notice: '', product_type: 'service', rate: 0.0, region: 'NY', tax_behavior: 'exclusive',
              tax_code: 'ebook', taxable_part: nil, import: true, subtotal: nil, tax_amount: nil, total_amount: nil
            }
          },
          {
            description: 'Awesome SaaS', quantity: 1, amount: 89,
            tax: {
              city: 'NEW YORK', country: 'US', county: 'NEW YORK', currency: 'USD', name: 'Sales tax', notes: nil,
              notice: '', product_type: 'service', rate: 8.875, region: 'NY', tax_behavior: 'exclusive',
              tax_code: 'saas', taxable_part: 100.0, import: true, subtotal: nil, tax_amount: nil, total_amount: nil
            }
          }
        ],
        payment: { method: 'credit_card', processor: 'processor12345', processor_id: 'txn_12345' },
        processor: 'processor12345', processor_id: 'txn_12345', po_number: 'PO_12345',
        tags: 'tag-a,tag-b,tag-c',
        custom_metadata: { anything_you_want: 'extra info' }
      }

      VCR.use_cassette('new sale') do
        @transaction = Quaderno::Transaction.create(sale_params)
      end

      expect(@transaction.is_a?(Quaderno::Transaction)).to be true
      expect(@transaction.type).to eq 'Invoice'
      expect(@transaction.currency).to eq sale_params[:currency]
      expect(@transaction.items.count).to eq sale_params[:items].count
      expect(@transaction.total_cents).to eq(sale_params[:items].sum { |item| item[:amount] * 100 })
      expect(@transaction.contact.full_name).to eq "#{sale_params[:customer][:first_name]} #{sale_params[:customer][:last_name]}"
    end

    it 'should create a refund transaction' do
      refund_params = {
        type: 'refund', customer: { first_name: 'John', last_name: 'Smith', email: 'an_email@example.com' },
        evidence: { billing_country: 'US', ip_address: '255.255.255.255', bank_country: 'US' },
        currency: 'USD',
        items: [
          {
            description: 'Awesome ebook', quantity: 1, amount: 19,
            tax: {
              city: nil, country: 'US', county: nil, currency: 'USD', name: nil, notes: nil,
              notice: '', product_type: 'service', rate: 0.0, region: 'NY', tax_behavior: 'exclusive',
              tax_code: 'ebook', taxable_part: nil, import: true, subtotal: nil, tax_amount: nil, total_amount: nil
            }
          },
          {
            description: 'Awesome SaaS', quantity: 1, amount: 89,
            tax: {
              city: 'NEW YORK', country: 'US', county: 'NEW YORK', currency: 'USD', name: 'Sales tax', notes: nil,
              notice: '', product_type: 'service', rate: 8.875, region: 'NY', tax_behavior: 'exclusive',
              tax_code: 'saas', taxable_part: 100.0, import: true, subtotal: nil, tax_amount: nil, total_amount: nil
            }
          }
        ],
        payment: { method: 'credit_card', processor: 'processor12345', processor_id: 'txn_12345' },
        processor: 'processor12345', processor_id: 'txn_12345', po_number: 'PO_12345',
        tags: 'tag-a,tag-b,tag-c',
        custom_metadata: { anything_you_want: 'extra info' }
      }

      VCR.use_cassette('new refund') do
        @transaction = Quaderno::Transaction.create(refund_params)
      end

      expect(@transaction.is_a?(Quaderno::Transaction)).to be true
      expect(@transaction.type).to eq 'Credit'
      expect(@transaction.currency).to eq refund_params[:currency]
      expect(@transaction.items.count).to eq refund_params[:items].count
      expect(@transaction.total_cents).to eq(refund_params[:items].sum { |item| item[:amount] * 100 })
      expect(@transaction.contact.full_name).to eq "#{refund_params[:customer][:first_name]} #{refund_params[:customer][:last_name]}"
    end
  end
end
