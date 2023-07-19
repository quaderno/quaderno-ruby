# frozen_string_literal: true

class Quaderno::TaxJurisdiction < Quaderno::Base
  class << self
    undef :create, :update, :delete, :parse_nested
  end

  api_model Quaderno::TaxJurisdiction
  api_path 'jurisdictions'
end
