require 'rubygems'
require 'bundler'
require 'ruby-debug'
require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/quaderno_cassettes'
  c.ignore_localhost = false
  c.hook_into :fakeweb
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'quaderno-ruby'

class Test::Unit::TestCase
end
