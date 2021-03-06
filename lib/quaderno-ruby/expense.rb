class Quaderno::Expense < Quaderno::Base
  include Quaderno::Behavior::Payment
  include Quaderno::Behavior::Block

  api_model Quaderno::Expense
  api_path 'expenses'
  is_a_document? true
end