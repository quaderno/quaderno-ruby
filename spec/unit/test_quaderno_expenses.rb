require 'helper'

class TestQuadernoExpense < Test::Unit::TestCase
  context 'A user with an authenticate token with expenses' do

    before(:each) do
      Quaderno::Base.configure do |config|
        config.auth_token = TEST_KEY
        config.url = TEST_URL
        config.api_version = nil
      end
    end

    it 'should get exception if pass wrong arguments' do
      assert_raise ArgumentError do
        VCR.use_cassette('all expenses') do
          Quaderno::Expense.all 1, 2, 3
        end
      end
      assert_raise ArgumentError do
        VCR.use_cassette('found expense') do
          Quaderno::Expense.find
        end
      end
    end

    it 'should get all expenses (populated db)' do
      VCR.use_cassette('all expenses') do
        expenses = Quaderno::Expense.all
        assert_not_nil expenses
        assert_kind_of Array, expenses
        expenses.each do |expense|
          assert_kind_of Quaderno::Expense, expense
        end
      end
    end

    it 'should find a expense' do
      VCR.use_cassette('found expense') do
        expenses = Quaderno::Expense.all
        expense = Quaderno::Expense.find expenses.first.id
        assert_kind_of Quaderno::Expense, expense
        assert_equal expenses.first.id, expense.id
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
        assert_kind_of Quaderno::Expense, expense
        assert_equal contacts.first.id, expense.contact.id
        assert_equal 'Aircraft', expense.items.first.description
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
        assert_kind_of Quaderno::Expense, expense
        assert_equal 'Updated expense!', expense.po_number
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
          assert_not_equal expenses.first.id, expense.id
        end
    end

    it 'should add a payment' do
      VCR.use_cassette('paid expense') do
        expenses = Quaderno::Expense.all
        payment = expenses.first.add_payment(payment_method: "cash", amount: "10000")
        assert_kind_of Quaderno::Payment, payment
        assert_equal "cash", payment.payment_method
        assert_equal 1000000, payment.amount_cents
        assert_equal expenses.first.payments.last.id, payment.id
      end
    end

    it 'should remove a payment' do
      VCR.use_cassette('unpay an expense') do
        expenses = Quaderno::Expense.all
        expenses.first.add_payment(payment_method: "cash", amount: "10000")
        payment = expenses.first.payments.last
        array_length = expenses.first.payments.length
        expenses.first.remove_payment(payment.id)
        assert_equal (array_length.zero? ? array_length : array_length-1), expenses.first.payments.length
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
        assert_kind_of Quaderno::Expense, expense
        assert !expense.total.nil?
        assert expense.total_cents.nil?
        assert_equal contacts.first.id, expense.contact.id
        assert_equal 'Aircraft', expense.items.first.description
        Quaderno::Expense.delete(expense.id)
      end
    end
  end
end