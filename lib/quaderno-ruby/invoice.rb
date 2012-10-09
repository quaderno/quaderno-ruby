module Quaderno
  class Invoice < Base
    include Quaderno::Behavior::Deliver
    include Quaderno::Behavior::Payment
    
    api_model Quaderno::Invoice
    api_path 'invoices'   
  end
end