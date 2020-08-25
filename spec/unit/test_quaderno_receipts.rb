require 'helper'

describe Quaderno::Receipt do
  context 'A user with an authenticate token with receipts' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end


    it 'should get all receipts (populated db)' do
      VCR.use_cassette('all receipts') do
        receipts = Quaderno::Receipt.all
        expect(receipts.is_a? Array).to be true
        receipts.each { |receipt| expect(receipt.is_a? Quaderno::Receipt).to be true }
      end
    end

    it 'should find a receipt' do
      VCR.use_cassette('found receipt') do
        receipts = Quaderno::Receipt.all
        receipt = Quaderno::Receipt.find receipts.first.id
        expect(receipt.is_a? Quaderno::Receipt).to be true
        expect(receipt.id).to eq receipts.first.id
      end
    end

    it 'should create a receipt' do
      VCR.use_cassette('new receipt') do
        contact = Quaderno::Contact.create(first_name: 'Test customer')
        receipt = Quaderno::Receipt.create(contact_id: contact.id ,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt',
                                           payment_method: :cash,
                                           notes: '')
        expect(receipt.is_a? Quaderno::Receipt).to be true
        expect(receipt.contact.id).to eq contact.id
        expect(receipt.items[0].description).to eq 'Aircraft'

        Quaderno::Receipt.delete(receipt.id)
        Quaderno::Contact.delete(contact.id)
      end
    end

    it 'should update an receipt' do
      VCR.use_cassette('updated receipt') do
        contact = Quaderno::Contact.create(first_name: 'Test customer')
        receipt = Quaderno::Receipt.create(contact_id: contact.id ,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt',
                                           payment_method: :cash,
                                           notes: '')
        receipt = Quaderno::Receipt.update(receipt.id, notes: 'Show me the moneeeeeeeyy!!!!')
        expect(receipt.is_a? Quaderno::Receipt).to be true
        expect(receipt.notes).to eq 'Show me the moneeeeeeeyy!!!!'

        Quaderno::Receipt.delete(receipt.id)
        Quaderno::Contact.delete(contact.id)
      end
    end

    it 'should delete an receipt' do
      VCR.use_cassette('deleted receipt') do
        contact = Quaderno::Contact.create(first_name: 'Test customer')
        receipt = Quaderno::Receipt.create(contact_id: contact.id ,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt',
                                           payment_method: :cash,
                                           notes: '')
        Quaderno::Receipt.delete receipt.id
        Quaderno::Contact.delete(contact.id)

        receipts = Quaderno::Receipt.all
        expect(receipt.id).not_to eq(receipts.first.id)
      end
    end

    it 'should deliver an receipt' do
      VCR.use_cassette('delivered receipt') do
        receipts = Quaderno::Receipt.all
        rate_limit_before = Quaderno::Base.ping.rate_limit_info
        begin
          rate_limit_after = receipts.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end

        expect(rate_limit_after[:remaining]).to eq(rate_limit_before[:remaining] - 1)
      end
    end

    it 'should override version' do
      Quaderno::Base.api_version = OLDEST_SUPPORTED_API_VERSION

      VCR.use_cassette('create receipt on downgraded API') do
        contact = Quaderno::Contact.create(first_name: 'Test customer')
        receipt = Quaderno::Receipt.create(contact_id: contact.id ,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt',
                                           payment_method: :cash,
                                           notes: '')

        expect(receipt.total_cents.nil?).to be true
        expect(!receipt.total.nil?).to be true
        expect(receipt.is_a? Quaderno::Receipt).to be true
        expect(receipt.contact.id).to eq contact.id
        expect(receipt.items[0].description).to eq 'Aircraft'

        Quaderno::Receipt.delete(receipt.id)
        Quaderno::Contact.delete(contact.id)
      end
    end
  end
end