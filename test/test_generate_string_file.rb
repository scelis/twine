require 'twine_test_case'

class TestGenerateStringFile < TwineTestCase
  def prepare_mock_formatter(formatter_class)
    formatter = formatter_class.new(@mock_strings, {})
    formatter_class.stubs(:new).returns(formatter)
    formatter.expects(:write_file)
  end

  def setup
    super

    @known_languages = %w(en fr de sp)

    @mock_strings = Twine::StringsFile.new
    @mock_strings.language_codes.concat @known_languages
    Twine::StringsFile.stubs(:new).returns(@mock_strings)

    @mock_android_formatter = Twine::Formatters::Android.new(@mock_strings, {})
    Twine::Formatters::Android.stubs(:new).returns(@mock_android_formatter)
  end

  def test_deducts_android_format_from_output_path
    options = {
      output_path: File.join(@output_dir, 'fr.xml'),
      languages: ['fr']
    }
    runner = Twine::Runner.new(nil, options)

    @mock_android_formatter.expects(:write_file)

    runner.generate_string_file
  end

  def test_deducts_apple_format_from_output_path
    prepare_mock_formatter Twine::Formatters::Apple
    options = {
      output_path: File.join(@output_dir, 'fr.strings'),
      languages: ['fr']
    }
    runner = Twine::Runner.new(nil, options)

    runner.generate_string_file
  end

  def test_deducts_jquery_format_from_output_path
    prepare_mock_formatter Twine::Formatters::JQuery
    options = {
      output_path: File.join(@output_dir, 'fr.json'),
      languages: ['fr']
    }
    runner = Twine::Runner.new(nil, options)

    runner.generate_string_file
  end

  def test_deducts_gettext_format_from_output_path
    prepare_mock_formatter Twine::Formatters::Gettext
    options = {
      output_path: File.join(@output_dir, 'fr.po'),
      languages: ['fr']
    }
    runner = Twine::Runner.new(nil, options)

    runner.generate_string_file
  end

  def test_deducts_language_from_output_path
    random_language = @known_languages.sample
    options = {
      output_path: File.join(@output_dir, "#{random_language}.xml"),
    }
    runner = Twine::Runner.new(nil, options)

    @mock_android_formatter.expects(:write_file).with(anything, random_language)

    runner.generate_string_file
  end
end
