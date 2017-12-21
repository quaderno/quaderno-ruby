require 'ostruct'

require 'quaderno-ruby/exceptions/exceptions'
require 'quaderno-ruby/helpers/authentication'
require 'quaderno-ruby/collection'

%w(block crud deliver payment retrieve).each { |filename| require "quaderno-ruby/behavior/#{filename}" }
%w(base contact item invoice receipt credit income estimate expense recurring document_item report evidence payment webhook tax).each { |filename| require "quaderno-ruby/#{ filename }" }

class Quaderno
end