# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formally/version'

Gem::Specification.new do |spec|
  spec.name          = 'formally'
  spec.version       = Formally::VERSION
  spec.authors       = ['James Dabbs']
  spec.email         = ['jamesdabbs@gmail.com']

  spec.summary       = %q{Form object helpers built on top of dry-validations}
  spec.homepage      = 'https://github.com/jamesdabbs/formally'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-validation', '~> 0.11.1'

  spec.add_development_dependency 'bundler',   '~> 1.14'
  spec.add_development_dependency 'faker',     '~> 1.8' 
  spec.add_development_dependency 'rake',      '~> 10.0'
  spec.add_development_dependency 'rspec',     '~> 3.0'
  spec.add_development_dependency 'pry',       '~> 0.11'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end
