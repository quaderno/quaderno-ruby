$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'vcr'
require 'test/unit'
require 'shoulda-context'
require 'quaderno-ruby'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/quaderno_cassettes'
  c.ignore_localhost = false
  c.hook_into :fakeweb
end

TEST_URL = 'http://development.lvh.me:3000/api/'
TEST_KEY = 'sk_test_B7xXrTspfeGukQqGN1pK'
TEST_OAUTH_ACCESS_TOKEN = '36b82411e6686581fe3d7d10fbe931a3fdc9265a353832f0e3ff6269bd319e12'
OLDEST_SUPPORTED_API_VERSION = 20160602

class Test::Unit::TestCase
end
