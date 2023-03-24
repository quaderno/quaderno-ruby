# frozen_string_literal: true

class Quaderno::Transaction < Quaderno::Base
  api_model Quaderno::Transaction
  api_path 'transactions'
  is_a_document? true

  class << self
    undef :all, :find, :update, :delete
  end
end
