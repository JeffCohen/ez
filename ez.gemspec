# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ez/version'

Gem::Specification.new do |spec|
  spec.name          = "ez"
  spec.version       = EZ::VERSION
  spec.authors       = ["Jeff Cohen"]
  spec.email         = ["cohen.jeff@gmail.com"]
  spec.description   = "Gem for easier Rails development."
  spec.summary       = "For educational purposes only."
  spec.homepage      = "http://www.jeffcohenonline.com/ez"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'awesome_print'
  spec.add_runtime_dependency 'hirb', '~> 0.7'

  spec.add_development_dependency "byebug", "~> 9.1.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", '~> 10.0', '>= 10.0.0'
end
