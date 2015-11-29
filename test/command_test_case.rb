require 'twine_test_case'

class CommandTestCase < TwineTestCase
  def prepare_mock_formatter(formatter_class)
    strings = Twine::StringsFile.new
    strings.language_codes.concat KNOWN_LANGUAGES

    formatter = formatter_class.new(strings, {})
    formatter_class.stubs(:new).returns(formatter)
    formatter
  end
end
