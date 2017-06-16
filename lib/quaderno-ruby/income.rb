module Quaderno
  class Income < Base
    include Quaderno::Behavior::Block

    class << self
      undef :find, :create, :update, :delete
    end

    api_model Quaderno::Income
    api_path 'income'
    is_a_document? true
  end
end