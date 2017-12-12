require 'command_test'

class TestGenerateLocalizationFile < CommandTest
  def new_runner(language, file, options = {})
    options[:output_path] = File.join(@output_dir, file) if file
    options[:languages] = language if language

    twine_file = Twine::TwineFile.new
    twine_file.language_codes.concat KNOWN_LANGUAGES

    Twine::Runner.new(options, twine_file)
  end

  def prepare_mock_format_file_formatter(formatter_class)
    formatter = prepare_mock_formatter(formatter_class)
    formatter.expects(:format_file).returns(true)
  end

  def test_deducts_android_format_from_output_path
    prepare_mock_format_file_formatter Twine::Formatters::Android

    new_runner('fr', 'fr.xml').generate_localization_file
  end

  def test_deducts_apple_format_from_output_path
    prepare_mock_format_file_formatter Twine::Formatters::Apple

    new_runner('fr', 'fr.strings').generate_localization_file
  end

  def test_deducts_jquery_format_from_output_path
    prepare_mock_format_file_formatter Twine::Formatters::JQuery

    new_runner('fr', 'fr.json').generate_localization_file
  end

  def test_deducts_gettext_format_from_output_path
    prepare_mock_format_file_formatter Twine::Formatters::Gettext

    new_runner('fr', 'fr.po').generate_localization_file
  end

  def test_deducts_django_format_from_output_path
    prepare_mock_format_file_formatter Twine::Formatters::Django

    new_runner('fr', 'fr.po').generate_localization_file
  end

  def test_returns_error_for_ambiguous_output_path
    # both Gettext and Django use .po
    gettext_formatter = prepare_mock_formatter(Twine::Formatters::Gettext)
    gettext_formatter.stubs(:format_file).returns(true)
    django_formatter = prepare_mock_formatter(Twine::Formatters::Django, false)
    django_formatter.stubs(:format_file).returns(true)

    assert_raises Twine::Error do
      new_runner('fr', 'fr.po').generate_localization_file
    end
  end

  def test_uses_specified_formatter_to_resolve_ambiguity
    # both Android and Tizen use .xml
    android_formatter = prepare_mock_formatter(Twine::Formatters::Android)
    android_formatter.stubs(:format_file).returns(true)
    tizen_formatter = prepare_mock_formatter(Twine::Formatters::Tizen, false)
    tizen_formatter.stubs(:format_file).returns(true)

    # implicit assert that this call doesn't raise an exception
    new_runner('fr', 'fr.xml', format: 'android').generate_localization_file
  end

  def test_deducts_language_from_output_path
    random_language = KNOWN_LANGUAGES.sample
    formatter = prepare_mock_formatter Twine::Formatters::Android
    formatter.expects(:format_file).with(random_language).returns(true)

    new_runner(nil, "#{random_language}.xml").generate_localization_file
  end

  def test_returns_error_if_nothing_written
    formatter = prepare_mock_formatter Twine::Formatters::Android
    formatter.expects(:format_file).returns(false)

    assert_raises Twine::Error do
      new_runner('fr', 'fr.xml').generate_localization_file
    end
  end

  class TestValidate < CommandTest
    def new_runner(validate)
      options = {}
      options[:output_path] = @output_path
      options[:languages] = ['en']
      options[:format] = 'android'
      options[:validate] = validate

      twine_file = build_twine_file 'en' do
        add_section 'Section' do
          add_definition key: 'value'
          add_definition key: 'value'
        end
      end

      Twine::Runner.new(options, twine_file)
    end

    def test_does_not_validate_twine_file
      prepare_mock_formatter Twine::Formatters::Android

      new_runner(false).generate_localization_file
    end

    def test_validates_twine_file_if_validate
      assert_raises Twine::Error do
        new_runner(true).generate_localization_file
      end
    end
  end
end
