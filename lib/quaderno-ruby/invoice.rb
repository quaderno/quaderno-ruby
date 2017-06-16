module Quaderno
  class Invoice < Base
    include Quaderno::Behavior::Deliver
    include Quaderno::Behavior::Payment
    include Quaderno::Behavior::Retrieve
    include Quaderno::Behavior::Block

    api_model Quaderno::Invoice
    api_path 'invoices'
    retrieve_path 'charges'
    is_a_document? true
  end
end