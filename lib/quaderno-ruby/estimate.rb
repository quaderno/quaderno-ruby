module Quaderno
  class Estimate < Base
    include Quaderno::Behavior::Deliver

    api_model Quaderno::Estimate
    api_path 'estimates'
    is_a_document? true
  end
end