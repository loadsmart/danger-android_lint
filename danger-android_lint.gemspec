# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'android_lint/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-android_lint'
  spec.version       = AndroidLint::VERSION
  spec.authors       = ['Gustavo Barbosa']
  spec.email         = ['gustavo@loadsmart.com']
  spec.description   = %q{A Danger plugin for Android Lint}
  spec.summary       = %q{Lint files of a gradle based Android project. This is done using the Android's Lint tool. Results are passed out as tables in markdown.}
  spec.homepage      = 'https://github.com/loadsmart/danger-android_lint'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'oga'

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 13.0'

  # Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'

  # Linting code and docs
  spec.add_development_dependency "rubocop", "~> 0.49.0"
  spec.add_development_dependency "yard", "~> 0.9.11"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'
end
