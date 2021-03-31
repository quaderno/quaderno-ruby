require 'helper'

describe Quaderno::Invoice do
  context 'A user with an authenticate token with invoices' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all invoices (populated db)' do
      VCR.use_cassette('all invoices') do
        invoices = Quaderno::Invoice.all
        expect(invoices.is_a? Array).to be true
        invoices.each { |invoice| expect(invoice.is_a? Quaderno::Invoice).to be true }
      end
    end

    it 'should paginate invoices' do
      VCR.use_cassette('paginated_invoices') do
        invoices = Quaderno::Invoice.all
        expect(invoices.has_more?).to be true
        second_page = invoices.next_page
        expect(second_page.map(&:id)).not_to include(invoices.map(&:id))
      end
    end

    it 'should find a invoice' do
      VCR.use_cassette('found invoice') do
        invoices = Quaderno::Invoice.all
        invoice = Quaderno::Invoice.find invoices.first.id
        expect(invoice.is_a? Quaderno::Invoice).to be true
        expect(invoice.id).to eq  invoices.first.id
      end
    end

    it 'should create a invoice' do
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
        expect(invoice.is_a? Quaderno::Invoice).to be true
        expect(invoice.contact.id).to eq contacts[0].id
        expect(invoice.items[0].description).to eq 'Aircraft'

        Quaderno::Invoice.delete(invoice.id)
      end
    end

    it 'should update an invoice' do
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
        expect(invoice.is_a? Quaderno::Invoice).to be true
        expect(invoice.payment_details).to eq 'Show me the moneeeeeeeyy!!!!'

        Quaderno::Invoice.delete(invoice.id)
      end
    end

    it 'should delete an invoice' do
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
        expect(invoice.id).not_to eq invoices.first.id
      end
    end

    it 'should deliver an invoice' do
      VCR.use_cassette('delivered invoice') do
        invoices = Quaderno::Invoice.all
        rate_limit_before = Quaderno::Base.ping.rate_limit_info
        begin
          rate_limit_after = invoices.first.deliver
        rescue Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid
          rate_limit_after = { remaining: (rate_limit_before[:remaining] - 1) }
        end

        expect(rate_limit_after[:remaining]).to eq(rate_limit_before[:remaining] - 1)
      end
    end

    it 'should add a payment' do
      VCR.use_cassette('paid invoice') do
        invoices = Quaderno::Invoice.all
        payment = invoices.first.add_payment(payment_method: 'cash', amount: 100000000)

        expect(payment.is_a? Quaderno::Payment).to be true
        expect(payment.payment_method).to eq 'cash'
        expect(payment.amount_cents).to eq 10000000000
        expect(payment.id).to eq invoices.first.payments.last.id
      end
    end

    it 'should remove a payment' do
      VCR.use_cassette('unpay an invoice') do
        invoices = Quaderno::Invoice.all
        invoices.first.add_payment(payment_method: 'cash', amount: 100000000)
        payment = invoices.first.payments.last
        array_length = invoices.first.payments.length
        invoices.first.remove_payment(payment.id) unless payment.nil?

        expect(invoices.first.payments.length).to eq(array_length.zero? ? array_length : array_length - 1)
      end
    end

    it 'should override version' do
      Quaderno::Base.api_version = OLDEST_SUPPORTED_API_VERSION

      VCR.use_cassette('create invoice on downgraded API') do
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
        expect(invoice.total_cents.nil?).to be true
        expect(!invoice.total.nil?).to be true
        expect(invoice.is_a? Quaderno::Invoice).to be true
        expect(invoice.contact.id).to eq contacts[0].id
        expect(invoice.items[0].description).to eq('Aircraft')

        Quaderno::Invoice.delete(invoice.id)
      end
    end
  end
end
