$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
require 'debugger'

begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'vcr'
require 'test/unit'
require 'shoulda'
require 'quaderno-ruby'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/quaderno_cassettes'
  c.ignore_localhost = false
  c.hook_into :fakeweb
end

class Test::Unit::TestCase
end
