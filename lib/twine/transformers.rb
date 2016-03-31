
module Twine
  module Transformers
    @transformers = []

    class << self
      attr_reader :transformers

      ###
      # registers a new formatter
      #
      # formatter_class - the class of the formatter to register
      #
      # returns array of active formatters
      #
      def register_transformer transformer_class
        @transformers << transformer_class.new
      end
    end
  end
end


Dir[File.join(File.dirname(__FILE__), 'transformers', '*.rb')].each do |file|
  require file
end
