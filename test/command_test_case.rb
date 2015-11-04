require 'twine_test_case'

class CommandTestCase < TwineTestCase
  def prepare_mock_formatter(formatter_class)
    formatter = formatter_class.new(@mock_strings, {})
    formatter_class.stubs(:new).returns(formatter)
    formatter
  end

  def setup
    super

    @known_languages = %w(en fr de sp)

    @mock_strings = Twine::StringsFile.new
    @mock_strings.language_codes.concat @known_languages
    Twine::StringsFile.stubs(:new).returns(@mock_strings)
  end
end
