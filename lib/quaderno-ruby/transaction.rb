module Quaderno
  class Transaction < Base
    
    api_model Quaderno::Transaction
    api_path 'transactions'
    
    class << self
      undef :all, :update
    end
  end
end