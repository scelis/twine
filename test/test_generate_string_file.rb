require 'command_test_case'

class TestGenerateStringFile < CommandTestCase
  def new_runner(language, file)
    options = {}
    options[:output_path] = File.join(@output_dir, file) if file
    options[:languages] = language if language

    @strings = Twine::StringsFile.new
    @strings.language_codes.concat KNOWN_LANGUAGES

    Twine::Runner.new(nil, options, @strings)
  end

  def prepare_mock_write_file_formatter(formatter_class)
    formatter = prepare_mock_formatter(formatter_class)
    formatter.expects(:write_file)
  end

  def test_deducts_android_format_from_output_path
    prepare_mock_write_file_formatter Twine::Formatters::Android

    new_runner('fr', 'fr.xml').generate_string_file
  end

  def test_deducts_apple_format_from_output_path
    prepare_mock_write_file_formatter Twine::Formatters::Apple

    new_runner('fr', 'fr.strings').generate_string_file
  end

  def test_deducts_jquery_format_from_output_path
    prepare_mock_write_file_formatter Twine::Formatters::JQuery

    new_runner('fr', 'fr.json').generate_string_file
  end

  def test_deducts_gettext_format_from_output_path
    prepare_mock_write_file_formatter Twine::Formatters::Gettext

    new_runner('fr', 'fr.po').generate_string_file
  end

  def test_deducts_language_from_output_path
    random_language = KNOWN_LANGUAGES.sample
    formatter = prepare_mock_formatter Twine::Formatters::Android
    formatter.expects(:write_file).with(anything, random_language)

    new_runner(nil, "#{random_language}.xml").generate_string_file
  end
end
