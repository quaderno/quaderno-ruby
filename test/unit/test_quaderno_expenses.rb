require 'helper'

class TestQuadernoExpense < Test::Unit::TestCase
  context 'A user with an authenticate token with expenses' do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = 'xiZvifX5hwsxAiymYPk2'
        config.subdomain = 'recrea'
      end
    end

    should 'get exception if pass wrong arguments' do
      assert_raise ArgumentError do 
        VCR.use_cassette('all expenses') do
          Quaderno::Expense.all 1
        end
      end
      assert_raise ArgumentError do 
        VCR.use_cassette('found expense') do
          Quaderno::Expense.find
        end
      end
    end

    should 'get all expenses (populated db)' do
      VCR.use_cassette('all expenses') do
        expenses = Quaderno::Expense.all
        assert_not_nil expenses
        assert_kind_of Array, expenses
        expenses.each do |expense|
          assert_kind_of Quaderno::Expense, expense
        end
      end
    end

    should 'find a expense' do
      VCR.use_cassette('found expense') do
        expenses = Quaderno::Expense.all
        expense = Quaderno::Expense.find expenses[2].id
        assert_kind_of Quaderno::Expense, expense
        assert_equal expenses[2].id, expense.id
      end
    end
    
    should 'create a expense' do
      VCR.use_cassette('new expense') do
        expenses = Quaderno::Expense.all
        contacts = Quaderno::Contact.all
        expense = Quaderno::Expense.create(number: "#{ expenses.length + 1 }",
                                           contact_id: contacts[0].id ,
                                           contact_name: contacts[0].full_name, 
                                           currency: 'EUR', 
                                           items: [
                                             { 
                                               description: 'Aircraft', 
                                               quantity: '1.0', 
                                               unit_price: '0.0' 
                                             }
                                           ],
                                           tags: 'tnt', payment_details: '', 
                                           notes: '')
        assert_kind_of Quaderno::Expense, expense
        assert_equal contacts[0].id, expense.contact.id
        assert_equal 'Aircraft', expense.items[0].description
      end
    end
    
    should 'update an expense' do
      VCR.use_cassette('updated expense') do
        expenses = Quaderno::Expense.all
        expense = Quaderno::Expense.update(expenses[2].id, currency: 'USD')
        assert_kind_of Quaderno::Expense, expense
        assert_equal 'USD', expense.currency
      end
    end
    
    should 'delete an expense' do
        VCR.use_cassette('deleted expense') do
          expenses = Quaderno::Expense.all
          expense_id = expenses[2].id
          Quaderno::Expense.delete expense_id
          expenses = Quaderno::Expense.all
          assert_not_equal expenses[2].id, expense_id
        end
    end
    
    should 'add a payment' do
      VCR.use_cassette('paid expense') do
        expenses = Quaderno::Expense.all
        payment = expenses[0].add_payment(method: "cash", number: "100000000")
        assert_kind_of Quaderno::Payment, payment
        assert_equal "cash", payment.method
        assert_equal "100,000,000.00", payment.amount[1..-1]
        assert_equal expenses[0].payments.last.id, payment.id 
      end
    end
    
    should 'remove a payment' do
        VCR.use_cassette('unpay an expense') do
          expenses = Quaderno::Expense.all
          expenses[0].add_payment(method: "cash", number: "100000000")
          payment = expenses[0].payments.last
          array_length = expenses[0].payments.length
          expenses[0].remove_payment(payment.id) unless payment.nil?
          assert_equal (array_length.zero? ? array_length : array_length-1), expenses[0].payments.length   
        end
    end
  end
end