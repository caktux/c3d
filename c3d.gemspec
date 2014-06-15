# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'c3d/version'

Gem::Specification.new do |s|
  s.name              = "c3d"
  s.version           = VERSION
  s.platform          = Gem::Platform::RUBY
  s.summary           = "Contract Controlled Content Distribution using Ethereum Contracts to Distribute Content."
  s.homepage          = "https://github.com/ethereum-package-manager/c3d"
  s.authors           = [ "Casey Kuhlman" ]
  s.email             = "caseykuhlman@watershedlegal.com"

  s.date              = Time.now.strftime('%Y-%m-%d')
  s.has_rdoc          = false

  s.files             = `git ls-files`.split($/)
  s.executables       = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files        = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths     = ["lib"]

  s.add_dependency             'httparty', '~> 0.13'
  s.add_dependency             'celluloid', '~> 0.15'
  s.add_dependency             'commander', '~> 4.1.6'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'epm'

  s.description       = <<desc
  This gem is designed to assist in distribution mangement of content which is controlled by an Ethereum contract.
desc
end