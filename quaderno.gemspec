# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quaderno-ruby/version'

Gem::Specification.new do |spec|
  spec.name = "quaderno"
  spec.version = Quaderno::VERSION
  spec.authors = ["Recrea"]
  spec.email = "carlos@recrea.es"

  spec.summary = "Ruby wrapper for the Quaderno API (https://quaderno.io/docs/api)"
  spec.description = " A ruby wrapper for Quaderno API "
  spec.homepage = "http://github.com/quaderno/quaderno-ruby"
  spec.licenses = ["MIT"]

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)
  spec.date = "2017-12-21"
  spec.extra_rdoc_files = %w(LICENSE.txt README.md)


  spec.add_dependency('httparty', "~> 0.13.1")
  spec.add_development_dependency('rdoc', "~> 3.12")
  spec.add_development_dependency('activesupport', "~> 4.2.0")
  spec.add_development_dependency('webmock', "~> 1.22.6")
  spec.add_development_dependency('vcr', ">= 0")
  spec.add_development_dependency("bundler", "~> 1.11")
  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("rspec", "~> 3.0")
end
