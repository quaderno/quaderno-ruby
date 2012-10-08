require 'ostruct'

%w(crud deliver payment).each { |filename| require "quaderno-ruby/behavior/#{ filename }" }
%w(base contact invoice estimate expense item payment).each { |filename| require "quaderno-ruby/#{ filename }" }
require 'ruby-debug'


module Quaderno

end