module Quaderno
  class Estimate < Base
    include Quaderno::Behavior::Crud    
    include Quaderno::Behaviour::Deliver
    
    api_model Quaderno::Estimate
    api_path 'estimates'
  end
end