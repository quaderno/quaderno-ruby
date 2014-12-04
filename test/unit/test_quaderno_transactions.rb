require 'helper'

class TestQuadernoTransaction < Test::Unit::TestCase
  context "A user with an authenticate token with transactions" do

    setup do
      Quaderno::Base.configure do |config|
        config.auth_token = 'rkHqiPxs4VFHgtqqjYqw'
        config.subdomain = 'test-account'
        config.environment = :sandbox
      end
    end

    should "get exception if pass wrong arguments" do
      assert_raise ArgumentError do 
        VCR.use_cassette('found transaction') do
          Quaderno::Transaction.find
        end
      end
    end

    should "find a transaction" do
      VCR.use_cassette('found transaction') do
        transaction = Quaderno::Transaction.find 18

        assert_kind_of Quaderno::Transaction, transaction
        assert_equal "IGIC", transaction.tax_name
        assert_equal 7.0, transaction.tax_rate
        assert_equal 1200, transaction.amount
        assert_equal 84, transaction.tax_amount
        assert_equal 1284, transaction.total_amount
      end
    end
    
    should "create a transaction" do
      VCR.use_cassette('new transaction') do
        #Canarian company to a canarian consumer
        transaction = Quaderno::Transaction.create(country: 'ES', postal_code: '35003', iin: '424242', amount: 1200, ip: '85.155.157.215')
        
        assert_kind_of Quaderno::Transaction, transaction
        assert_equal "IGIC", transaction.tax_name
        assert_equal 7.0, transaction.tax_rate
        assert_equal 1200, transaction.amount
        assert_equal 84, transaction.tax_amount
        assert_equal 1284, transaction.total_amount

        transaction = Quaderno::Transaction.create(country: 'ES', postal_code: '35003', iin: '424242', amount: 1200, ip: '85.155.157.215')
        
        assert_kind_of Quaderno::Transaction, transaction
        assert_equal "IGIC", transaction.tax_name
        assert_equal 7.0, transaction.tax_rate
        assert_equal 1200, transaction.amount
        assert_equal 84, transaction.tax_amount
        assert_equal 1284, transaction.total_amount

        #Canarian company to a non Canarian Spanish consumer
        transaction = Quaderno::Transaction.create(country: 'ES', postal_code: '08080', iin: '424242', amount: 1200, ip: '85.155.156.215')
        
        assert_kind_of Quaderno::Transaction, transaction
        assert transaction.tax_name.nil?
        assert_equal 0, transaction.tax_rate
        assert_equal 1200, transaction.amount
        assert_equal 0, transaction.tax_amount
        assert_equal 1200, transaction.total_amount
      end
    end
    
    should "delete a transaction" do
      VCR.use_cassette('deleted transaction') do
        new_transaction = Quaderno::Transaction.create(country: 'ES', postal_code: '08080', iin: '424242', amount: 1200, ip: '85.155.156.215')
        Quaderno::Transaction.delete new_transaction.id
        assert_raise NoMethodError do
          Quaderno::Transaction.find new_transaction.id
        end
      end
    end
  end
end