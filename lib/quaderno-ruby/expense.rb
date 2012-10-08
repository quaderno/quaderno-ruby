module Quaderno
  class Expense < Base
    include Quaderno::Behavior::Crud    
    include Quaderno::Behavior::Payment
    
    api_model Quaderno::Expense
    api_path 'expenses'
  end
end