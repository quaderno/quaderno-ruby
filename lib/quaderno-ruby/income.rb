class Quaderno::Income < Quaderno::Base
  include Quaderno::Behavior::Block

  class << self
    undef :find, :update, :delete
  end

  api_model Quaderno::Income
  api_path 'income'
  is_a_document? true
end