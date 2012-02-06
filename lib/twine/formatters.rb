require 'twine/formatters/abstract'
require 'twine/formatters/android'
require 'twine/formatters/apple'

module Twine
  module Formatters
    FORMATTERS = [Formatters::Apple, Formatters::Android]
  end
end
