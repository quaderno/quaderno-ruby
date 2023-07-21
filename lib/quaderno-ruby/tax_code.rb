# frozen_string_literal: true

class Quaderno::TaxCode < Quaderno::Base
  class << self
    undef :create, :update, :delete, :parse_nested
  end

  api_model Quaderno::TaxCode
  api_path 'tax_codes'
end