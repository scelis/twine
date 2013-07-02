module Traduco
  class Error < StandardError
  end

  require 'traduco/cli'
  require 'traduco/encoding'
  require 'traduco/formatters'
  require 'traduco/runner'
  require 'traduco/l10nfile'
end
