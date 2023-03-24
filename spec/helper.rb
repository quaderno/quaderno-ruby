# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'quaderno-ruby'
require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/fixtures/quaderno_cassettes'
  c.ignore_localhost = false
  c.hook_into :webmock
end

TEST_URL = 'http://quaderno.lvh.me:3000/api/'
TEST_KEY = 'sk_test_bMz9mJJ5bZnWPwWGuV8y'
TEST_OAUTH_ACCESS_TOKEN = 'afa16c7478f0ba3be222e627c2571d4dd5dca47924996b13a3af377feca47ff0'
OLDEST_SUPPORTED_API_VERSION = 20160602
