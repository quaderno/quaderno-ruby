module Quaderno
  class Expense < Base
    include Quaderno::Behavior::Payment
    
    api_model Quaderno::Expense
    api_path 'expenses'
  end
end