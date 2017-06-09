require 'ostruct'

require 'quaderno-ruby/exceptions/exceptions'
require 'quaderno-ruby/helpers/authentication'
%w(crud deliver payment retrieve).each { |filename| require "quaderno-ruby/behavior/#{filename}" }
%w(base contact item invoice receipt credit estimate expense recurring document_item evidence payment webhook tax).each { |filename| require "quaderno-ruby/#{ filename }" }

module Quaderno

end