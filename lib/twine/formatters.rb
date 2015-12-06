module Twine
  module Formatters
    @formatters = []

    class << self
      attr_reader :formatters
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'formatters', '*.rb')].each do |file|
  require file
end
