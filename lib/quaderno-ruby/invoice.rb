module Quaderno
  class Invoice < Base
    include Quaderno::Behavior::Crud    
    include Quaderno::Behaviour::Deliver
    include Quaderno::Behavior::Payment
    
    api_model Quaderno::Invoice
    api_path 'invoices'   
  end
end