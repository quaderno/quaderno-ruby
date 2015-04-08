module Quaderno
  class Credit < Base
    include Quaderno::Behavior::Deliver
    include Quaderno::Behavior::Payment

    api_model Quaderno::Credit
    api_path 'credits'
    is_a_document? true
  end
end