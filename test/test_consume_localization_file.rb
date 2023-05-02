require 'command_test'

class TestConsumeLocalizationFile < CommandTest
  def new_runner(language, file)
    options = {}
    options[:output_path] = File.join(@output_dir, file) if file
    options[:input_path] = File.join(@output_dir, file) if file
    FileUtils.touch options[:input_path]
    options[:languages] = language if language

    @twine_file = Twine::TwineFile.new
    @twine_file.language_codes.concat KNOWN_LANGUAGES

    Twine::Runner.new(options, @twine_file)
  end

  def prepare_mock_read_formatter(formatter_class)
    formatter = prepare_mock_formatter(formatter_class)
    formatter.expects(:read)
  end

  def test_deducts_android_format_from_output_path
    prepare_mock_read_formatter Twine::Formatters::Android

    new_runner('fr', 'fr.xml').consume_localization_file
  end

  def test_deducts_apple_format_from_output_path
    prepare_mock_read_formatter Twine::Formatters::Apple

    new_runner('fr', 'fr.strings').consume_localization_file
  end

  def test_deducts_jquery_format_from_output_path
    prepare_mock_read_formatter Twine::Formatters::JQuery

    new_runner('fr', 'fr.json').consume_localization_file
  end

  def test_deducts_language_from_input_path
    random_language = KNOWN_LANGUAGES.sample
    formatter = prepare_mock_formatter Twine::Formatters::Android
    formatter.expects(:read).with(anything, random_language)

    new_runner(nil, "#{random_language}.xml").consume_localization_file
  end

  class TestEncodings < CommandTest
    class DummyFormatter < Twine::Formatters::Abstract
      attr_reader :content

      def extension
        '.dummy'
      end

      def format_name
        'dummy'
      end

      def read(io, lang)
        @content = io.read
      end
    end

    def new_runner(input_path, encoding = nil)
      options = {}
      options[:output_path] = @output_path
      options[:input_path] = input_path
      options[:encoding] = encoding if encoding
      options[:languages] = 'en'

      @twine_file = Twine::TwineFile.new
      @twine_file.language_codes.concat KNOWN_LANGUAGES

      Twine::Runner.new(options, @twine_file)
    end

    def setup
      super
      @expected_content = "Üß`\nda\n"
    end

    def test_reads_utf8
      formatter = prepare_mock_formatter DummyFormatter
      new_runner(fixture_path('enc_utf8.dummy')).consume_localization_file
      assert_equal @expected_content, formatter.content
    end

    def test_reads_utf16le_bom
      formatter = prepare_mock_formatter DummyFormatter
      new_runner(fixture_path('enc_utf16le_bom.dummy')).consume_localization_file
      assert_equal @expected_content, formatter.content
    end

    def test_reads_utf16be_bom
      formatter = prepare_mock_formatter DummyFormatter
      new_runner(fixture_path('enc_utf16be_bom.dummy')).consume_localization_file
      assert_equal @expected_content, formatter.content
    end

    def test_reads_utf16le
      formatter = prepare_mock_formatter DummyFormatter
      new_runner(fixture_path('enc_utf16le.dummy'), 'UTF-16LE').consume_localization_file
      assert_equal @expected_content, formatter.content
    end

    def test_reads_utf16be
      formatter = prepare_mock_formatter DummyFormatter
      new_runner(fixture_path('enc_utf16be.dummy'), 'UTF-16BE').consume_localization_file
      assert_equal @expected_content, formatter.content
    end
  end
end
