module Quaderno
  class Receipt < Base
    include Quaderno::Behavior::Deliver

    api_model Quaderno::Receipt
    api_path 'receipts'
    is_a_document? true
  end
end