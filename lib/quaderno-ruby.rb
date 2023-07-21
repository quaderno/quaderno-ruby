# frozen_string_literal: true

class Quaderno
end

require 'ostruct'

require 'quaderno-ruby/version'
require 'quaderno-ruby/helpers/rate_limit'
require 'quaderno-ruby/helpers/response'
require 'quaderno-ruby/exceptions/exceptions'
require 'quaderno-ruby/helpers/authentication'
require 'quaderno-ruby/collection'

%w[block crud deliver payment retrieve].each { |filename| require "quaderno-ruby/behavior/#{filename}" }
%w[base account address contact item transaction invoice receipt credit income estimate expense recurring document_item report report_request evidence payment webhook tax tax_id tax_rate tax_code tax_jurisdiction checkout_session].each { |filename| require "quaderno-ruby/#{filename}" }
