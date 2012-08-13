# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nike/version'

Gem::Specification.new do |gem|
  gem.name          = "nike"
  gem.version       = Nike::VERSION
  gem.authors       = ["Alex Skryl"]
  gem.email         = ["rut216@gmail.com"]
  gem.summary       = %q{A Ruby client for the Nike+ API}
  gem.description   = %q{A Ruby client for the Nike+ API with support for Run/GPS/HR Data}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency(%q<hashie>, [">= 1.2.0"])
  gem.add_dependency(%q<activesupport>, [">= 3.2.0"])
end
