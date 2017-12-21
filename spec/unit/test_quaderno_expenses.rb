require 'helper'

describe Quaderno::Expense do
  context 'A user with an authenticate token with expenses' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get all expenses (populated db)' do
      VCR.use_cassette('all expenses') do
        expenses = Quaderno::Expense.all
        expect(expenses.is_a? Array).to be true
        expenses.each { |expense| expect(expense.is_a? Quaderno::Expense).to be true }
      end
    end

    it 'should find a expense' do
      VCR.use_cassette('found expense') do
        expenses = Quaderno::Expense.all
        expense = Quaderno::Expense.find expenses.first.id
        expect(expense.is_a? Quaderno::Expense).to be true
        expect(expense.id).to eq expenses.first.id
      end
    end

    it 'should create a expense' do
      VCR.use_cassette('new expense') do
        expenses = Quaderno::Expense.all
        contacts = Quaderno::Contact.all
        expense = Quaderno::Expense.create(contact_id: contacts.first.id ,
                                           contact_name: contacts.first.full_name,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt', payment_details: '',
                                           notes: '')
        expect(expense.is_a? Quaderno::Expense).to be true
        expect(expense.contact.id).to eq contacts.first.id
        expect(expense.items.first.description).to eq 'Aircraft'

        Quaderno::Expense.delete(expense.id)
      end
    end

    it 'should update an expense' do
      VCR.use_cassette('updated expense') do
        contacts = Quaderno::Contact.all
        expense = Quaderno::Expense.create(contact_id: contacts.first.id ,
                                 contact_name: contacts.first.full_name,
                                 currency: 'EUR',
                                 items_attributes: [
                                   {
                                     description: 'Aircraft',
                                     quantity: '1.0',
                                     unit_price: '0.0'
                                   }
                                 ],
                                 tags: 'tnt', payment_details: '',
                                 notes: '')
        expense = Quaderno::Expense.update(expense.id, po_number: 'Updated expense!')
        expect(expense.is_a? Quaderno::Expense).to be true
        expect(expense.po_number).to eq 'Updated expense!'

        Quaderno::Expense.delete(expense.id)
      end
    end

    it 'should delete an expense' do
      VCR.use_cassette('deleted expense') do
        contacts = Quaderno::Contact.all
        expense = Quaderno::Expense.create(contact_id: contacts.first.id ,
                                           contact_name: contacts.first.full_name,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt', payment_details: '',
                                           notes: '')
        Quaderno::Expense.delete expense.id
        expenses = Quaderno::Expense.all
        expect(expense.id).not_to eq expenses.first.id
      end
    end

    it 'should add a payment' do
      VCR.use_cassette('paid expense') do
        expenses = Quaderno::Expense.all
        payment = expenses.first.add_payment(payment_method: "cash", amount: "10000")
        expect(payment.is_a? Quaderno::Payment).to be true
        expect(payment.payment_method).to eq 'cash'
        expect(payment.amount_cents).to eq 1000000
        expect(payment.id).to eq expenses.first.payments.last.id
      end
    end

    it 'should remove a payment' do
      VCR.use_cassette('unpay an expense') do
        expenses = Quaderno::Expense.all
        expenses.first.add_payment(payment_method: "cash", amount: "10000")
        payment = expenses.first.payments.last
        array_length = expenses.first.payments.length
        expenses.first.remove_payment(payment.id)
        expect(expenses.first.payments.length).to eq(array_length.zero? ? array_length : array_length-1)
      end
    end

    it 'should override version' do
      Quaderno::Base.api_version = OLDEST_SUPPORTED_API_VERSION

      VCR.use_cassette('create expense on downgraded API') do
        expenses = Quaderno::Expense.all
        contacts = Quaderno::Contact.all
        expense = Quaderno::Expense.create(contact_id: contacts.first.id ,
                                           contact_name: contacts.first.full_name,
                                           currency: 'EUR',
                                           items_attributes: [
                                             {
                                               description: 'Aircraft',
                                               quantity: '1.0',
                                               unit_price: '0.0'
                                             }
                                           ],
                                           tags: 'tnt', payment_details: '',
                                           notes: '')
        expect(expense.is_a? Quaderno::Expense).to be true
        expect(!expense.total.nil?).to be true
        expect(expense.total_cents.nil?).to be true
        expect(expense.contact.id).to eq contacts.first.id
        expect(expense.items.first.description).to eq 'Aircraft'

        Quaderno::Expense.delete(expense.id)
      end
    end
  end
end