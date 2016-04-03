require 'twine_test_case'

class CommandTestCase < TwineTestCase
  def prepare_mock_formatter(formatter_class)
    twine_file = Twine::TwineFile.new
    twine_file.language_codes.concat KNOWN_LANGUAGES

    formatter = formatter_class.new
    formatter.twine_file = twine_file
    Twine::Formatters.formatters.clear
    Twine::Formatters.formatters << formatter
    formatter
  end
end
