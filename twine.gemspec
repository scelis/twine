$LOAD_PATH.unshift 'lib'
require 'twine/version'

Gem::Specification.new do |s|
  s.name         = "twine"
  s.version      = Twine::VERSION
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = "Manage strings and their translations for your iOS, Android and other projects."
  s.homepage     = "https://github.com/scelis/twine"
  s.email        = "twine@mobiata.com"
  s.authors      = [ "Sebastian Celis" ]
  s.license      = "BSD-3-Clause"

  s.files        = %w( Gemfile README.md LICENSE )
  s.files       += Dir.glob("lib/**/*")
  s.files       += Dir.glob("bin/**/*")
  s.files       += Dir.glob("test/**/*")
  s.test_files   = Dir.glob("test/test_*")

  s.required_ruby_version = ">= 2.6"
  s.add_runtime_dependency('rexml', "~> 3.2")
  s.add_runtime_dependency('rubyzip', "~> 2.0")
  s.add_runtime_dependency('safe_yaml', "~> 1.0")
  s.add_runtime_dependency('base64', "~> 0.2")
  s.add_development_dependency('rake', "~> 13.0")
  s.add_development_dependency('minitest', "~> 5.5")
  s.add_development_dependency('minitest-ci', "~> 3.0")
  s.add_development_dependency('mocha', "~> 2.7")

  s.executables  = %w( twine )
  s.description  = <<desc
  Twine is a command line tool for managing your strings and their translations.

  It is geared toward Mac OS X, iOS, and Android developers.
desc
end
