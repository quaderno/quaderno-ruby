module Quaderno
  class Expense < Base
    include Quaderno::Behavior::Crud    
    
    api_model Quaderno::Expense
    api_path 'expenses'
    
  end
end