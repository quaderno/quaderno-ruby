class Quaderno::Evidence < Quaderno::Base
  api_model Quaderno::Evidence
  api_path 'evidences'

  class << self
    undef :all, :find, :update, :delete, :parse_nested
  end
end