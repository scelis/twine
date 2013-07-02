require 'traduco/formatters/abstract'
require 'traduco/formatters/android'
require 'traduco/formatters/apple'
require 'traduco/formatters/flash'
require 'traduco/formatters/gettext'
require 'traduco/formatters/jquery'

module Traduco
  module Formatters
    FORMATTERS = [Formatters::Apple, Formatters::Android, Formatters::Gettext, Formatters::JQuery, Formatters::Flash]
  end
end
