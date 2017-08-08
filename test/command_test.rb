require 'twine_test'

class CommandTest < TwineTest
  def prepare_mock_formatter(formatter_class, clear_other_formatters = true)
    twine_file = Twine::TwineFile.new
    twine_file.language_codes.concat KNOWN_LANGUAGES

    formatter = formatter_class.new
    formatter.twine_file = twine_file
    Twine::Formatters.formatters.clear if clear_other_formatters
    Twine::Formatters.formatters << formatter
    formatter
  end
end
