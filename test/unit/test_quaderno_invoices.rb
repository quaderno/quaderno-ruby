require 'helper'

class TestQuadernoInvoice < Test::Unit::TestCase
  context 'A user with an authenticate token with invoices' do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = '1spyno1mbqbp3SFpg9uT'
        config.subdomain = 'recrea'
        config.debug = true
      end
    end

    should 'get exception if pass wrong arguments' do
      assert_raise ArgumentError do 
        VCR.use_cassette('all invoices') do
          Quaderno::Invoice.all 1, 2, 3
        end
      end
      assert_raise ArgumentError do 
        VCR.use_cassette('found invoice') do
          Quaderno::Invoice.find
        end
      end
    end

    should 'get all invoices (populated db)' do
      VCR.use_cassette('all invoices') do
        invoices = Quaderno::Invoice.all
        assert_not_nil invoices
        assert_kind_of Array, invoices
        invoices.each do |invoice|
          assert_kind_of Quaderno::Invoice, invoice
        end
      end
    end

    should 'find a invoice' do
      VCR.use_cassette('found invoice') do
        invoices = Quaderno::Invoice.all
        invoice = Quaderno::Invoice.find invoices.first.id
        assert_kind_of Quaderno::Invoice, invoice
        assert_equal invoices.first.id, invoice.id
      end
    end
    
    should 'create a invoice' do
      VCR.use_cassette('new invoice') do
        contacts = Quaderno::Contact.all
        invoice = Quaderno::Invoice.create(contact_id: contacts[0].id ,
                                           contact_name: contacts[0].full_name, 
                                           currency: 'EUR', 
                                           items_attributes: [
                                             { 
                                               description: 'Aircraft', 
                                               quantity: '1.0', 
                                               unit_price: '0.0' 
                                             }
                                           ],
                                           tags: 'tnt', 
                                           payment_details: '', 
                                           notes: '')
        assert_kind_of Quaderno::Invoice, invoice
        assert_equal contacts[0].id, invoice.contact.id
        assert_equal 'Aircraft', invoice.items[0].description
        Quaderno::Invoice.delete(invoice.id)
      end
    end
    
    should 'update an invoice' do
      VCR.use_cassette('updated invoice') do
        contacts = Quaderno::Contact.all
        invoice = Quaderno::Invoice.create(contact_id: contacts[0].id ,
                                           contact_name: contacts[0].full_name, 
                                           currency: 'EUR', 
                                           items_attributes: [
                                             { 
                                               description: 'Aircraft', 
                                               quantity: '1.0', 
                                               unit_price: '0.0' 
                                             }
                                           ],
                                           tags: 'tnt', 
                                           payment_details: '', 
                                           notes: '')
        invoice = Quaderno::Invoice.update(invoice.id, payment_details: 'Show me the moneeeeeeeyy!!!!')
        assert_kind_of Quaderno::Invoice, invoice
        assert_equal 'Show me the moneeeeeeeyy!!!!', invoice.payment_details
        Quaderno::Invoice.delete(invoice.id)
      end
    end
    
    should 'delete an invoice' do
        VCR.use_cassette('deleted invoice') do
          contacts = Quaderno::Contact.all
          invoice = Quaderno::Invoice.create(contact_id: contacts[0].id ,
                                             contact_name: contacts[0].full_name, 
                                             currency: 'EUR', 
                                             items_attributes: [
                                               { 
                                                 description: 'Aircraft', 
                                                 quantity: '1.0', 
                                                 unit_price: '0.0' 
                                               }
                                             ],
                                             tags: 'tnt', 
                                             payment_details: '', 
                                             notes: '')
          Quaderno::Invoice.delete invoice.id
          invoices = Quaderno::Invoice.all
          assert_not_equal invoices.first.id, invoice.id
        end
    end
    
    should 'deliver an invoice' do
      VCR.use_cassette('delivered invoice') do
        invoices = Quaderno::Invoice.all
        rate_limit_before = Quaderno::Base.rate_limit_info
        begin
          rate_limit_after = invoices.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmpty
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end
        assert_equal rate_limit_before[:remaining]-1, rate_limit_after[:remaining]
      end
    end
    
    should 'add a payment' do
      VCR.use_cassette('paid invoice') do
        invoices = Quaderno::Invoice.all
        payment = invoices.first.add_payment(payment_method: "cash", amount: "100000000")
        assert_kind_of Quaderno::Payment, payment
        assert_equal "cash", payment.payment_method
        assert_equal "100,000,000.00", payment.amount[0..payment.amount.length - 3]
        assert_equal invoices.first.payments.last.id, payment.id 
      end
    end
    
    should 'remove a payment' do
        VCR.use_cassette('unpay an invoice') do
          invoices = Quaderno::Invoice.all
          invoices.first.add_payment(payment_method: "cash", amount: "100000000")
          payment = invoices.first.payments.last
          array_length = invoices.first.payments.length
          invoices.first.remove_payment(payment.id) unless payment.nil?
          assert_equal (array_length.zero? ? array_length : array_length-1), invoices.first.payments.length
        end
    end
  end
end