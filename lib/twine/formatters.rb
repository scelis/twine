Dir[File.join(File.dirname(__FILE__), 'formatters', '*.rb')].each do |file|
  require file
end

module Twine
  module Formatters
    @formatters = [Formatters::Apple.new, Formatters::Android.new, Formatters::Gettext.new, Formatters::JQuery.new, Formatters::Flash.new, Formatters::Django.new, Formatters::Tizen.new]

    class << self
      attr_reader :formatters

      ###
      # registers a new formatter
      #
      # formatter_class - the class of the formatter to register
      #
      # returns array of active formatters
      #
      def register_formatter formatter_class
        raise "#{formatter_class} already registered" if @formatters.include? formatter_class
        @formatters << formatter_class
      end
    end
  end
end
