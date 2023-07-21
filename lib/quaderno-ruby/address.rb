# frozen_string_literal: true

class Quaderno::Address < Quaderno::Base
  api_model Quaderno::Address
  api_path 'addresses'

  class << self
    undef :delete
  end
end
