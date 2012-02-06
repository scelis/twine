$LOAD_PATH.unshift 'lib'
require 'twine/version'

Gem::Specification.new do |s|
  s.name         = "twine"
  s.version      = Twine::VERSION
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = "Manage strings and their translations for your iOS and Android projects."
  s.homepage     = "https://github.com/mobiata/twine"
  s.email        = "twine@mobiata.com"
  s.authors      = [ "Sebastian Celis" ]
  s.has_rdoc     = false

  s.files        = %w( Gemfile README.md LICENSE )
  s.files       += Dir.glob("lib/**/*")
  s.files       += Dir.glob("bin/**/*")

  s.add_runtime_dependency('rubyzip', "~> 0.9.5")

  s.executables  = %w( twine )
  s.description  = <<desc
  Twine is a command line tool for managing your strings and their translations.
  
  It is geared toward Mac OS X, iOS, and Android developers.
desc
end
