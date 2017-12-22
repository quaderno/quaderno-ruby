class Quaderno::Credit < Quaderno::Base
  include Quaderno::Behavior::Deliver
  include Quaderno::Behavior::Payment
  include Quaderno::Behavior::Retrieve
  include Quaderno::Behavior::Block

  api_model Quaderno::Credit
  api_path 'credits'
  retrieve_path 'refunds'
  is_a_document? true
end
