module Twine
  class Error < StandardError
  end

  require 'twine/plugin'
  require 'twine/cli'
  require 'twine/encoding'
  require 'twine/output_processor'
  require 'twine/placeholders'
  require 'twine/formatters'
  require 'twine/runner'
  require 'twine/stringsfile'
  require 'twine/version'
end
