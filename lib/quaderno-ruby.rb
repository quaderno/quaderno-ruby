require 'ostruct'

require 'quaderno-ruby/exceptions/exceptions'
%w(crud deliver payment).each { |filename| require "quaderno-ruby/behavior/#{ filename }" }
%w(base contact item invoice estimate expense document_item payment).each { |filename| require "quaderno-ruby/#{ filename }" }
require 'ruby-debug'


module Quaderno

end