require 'helper'

class TestQuadernoReceipt < Test::Unit::TestCase
  context 'A user with an authenticate token with receipts' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get exception if pass wrong arguments' do
      assert_raise ArgumentError do
        VCR.use_cassette('all receipts') do
          Quaderno::Receipt.all 1, 2, 3
        end
      end
      assert_raise ArgumentError do
        VCR.use_cassette('found receipt') do
          Quaderno::Receipt.find
        end
      end
    end

    it 'should get all receipts (populated db)' do
      VCR.use_cassette('all receipts') do
        receipts = Quaderno::Receipt.all
        assert_not_nil receipts
        assert_kind_of Array, receipts
        receipts.each do |receipt|
          assert_kind_of Quaderno::Receipt, receipt
        end
      end
    end

    it 'should find a receipt' do
      VCR.use_cassette('found receipt') do
        receipts = Quaderno::Receipt.all
        receipt = Quaderno::Receipt.find receipts.first.id
        assert_kind_of Quaderno::Receipt, receipt
        assert_equal receipts.first.id, receipt.id
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
        assert_kind_of Quaderno::Receipt, receipt
        assert_equal contact.id, receipt.contact.id
        assert_equal 'Aircraft', receipt.items[0].description
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
        assert_kind_of Quaderno::Receipt, receipt
        assert_equal 'Show me the moneeeeeeeyy!!!!', receipt.notes
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
          assert_not_equal receipts.first.id, receipt.id
        end
    end

    it 'should deliver an receipt' do
      VCR.use_cassette('delivered receipt') do
        receipts = Quaderno::Receipt.all
        rate_limit_before = Quaderno::Base.rate_limit_info
        begin
          rate_limit_after = receipts.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end
        assert_equal rate_limit_before[:remaining]-1, rate_limit_after[:remaining]
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
        assert receipt.total_cents.nil?
        assert !receipt.total.nil?
        assert_kind_of Quaderno::Receipt, receipt
        assert_equal contact.id, receipt.contact.id
        assert_equal 'Aircraft', receipt.items[0].description
        Quaderno::Receipt.delete(receipt.id)
        Quaderno::Contact.delete(contact.id)
      end
    end
  end
end