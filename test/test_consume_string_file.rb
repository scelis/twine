require 'command_test_case'

class TestConsumeStringFile < CommandTestCase
  def new_runner(language, file)
    options = {}
    options[:output_path] = File.join(@output_dir, file) if file
    options[:input_path] = File.join(@output_dir, file) if file
    FileUtils.touch options[:input_path]
    options[:languages] = language if language

    @strings = Twine::StringsFile.new
    @strings.language_codes.concat KNOWN_LANGUAGES

    Twine::Runner.new(options, @strings)
  end

  def prepare_mock_read_file_formatter(formatter_class)
    formatter = prepare_mock_formatter(formatter_class)
    formatter.expects(:read_file)
  end

  def test_deducts_android_format_from_output_path
    prepare_mock_read_file_formatter Twine::Formatters::Android

    new_runner('fr', 'fr.xml').consume_string_file
  end

  def test_deducts_apple_format_from_output_path
    prepare_mock_read_file_formatter Twine::Formatters::Apple

    new_runner('fr', 'fr.strings').consume_string_file
  end

  def test_deducts_jquery_format_from_output_path
    prepare_mock_read_file_formatter Twine::Formatters::JQuery

    new_runner('fr', 'fr.json').consume_string_file
  end

  def test_deducts_gettext_format_from_output_path
    prepare_mock_read_file_formatter Twine::Formatters::Gettext

    new_runner('fr', 'fr.po').consume_string_file
  end

  def test_deducts_language_from_input_path
    random_language = KNOWN_LANGUAGES.sample
    formatter = prepare_mock_formatter Twine::Formatters::Android
    formatter.expects(:read_file).with(anything, random_language)

    new_runner(nil, "#{random_language}.xml").consume_string_file
  end
end
