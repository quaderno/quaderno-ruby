require 'quaderno-ruby/behavior/crud'
%w(base contact invoice estimate expense payment).each { |filename| require "quaderno-ruby/#{ filename }" }



module Quaderno

end