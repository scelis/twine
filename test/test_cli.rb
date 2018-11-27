require 'twine_test'

class CLITest < TwineTest
  def setup
    super()

    @twine_file_path = File.join @output_dir, SecureRandom.uuid
    @input_path = File.join @output_dir, SecureRandom.uuid
    @input_dir = @output_dir
  end

  def parse(command)
    @options = Twine::CLI::parse command.split
  end

  def parse_with(parameters)
    raise "you need to implement `parse_with` in your test class"
  end

  def assert_help
    parse_with '--help'
    assert_equal @options, false
    assert_match /Usage: twine.*Examples:/m, Twine::stdout.string
  end

  def assert_option_consume_all
    parse_with '--consume-all'
    assert @options[:consume_all]
    parse_with '--no-consume-all'
    refute @options[:consume_all]
  end

  def assert_option_consume_comments
    parse_with '--consume-comments'
    assert @options[:consume_comments]
    parse_with '--no-consume-comments'
    refute @options[:consume_comments]
  end

  def assert_option_developer_language
    random_language = KNOWN_LANGUAGES.sample
    parse_with "--developer-language #{random_language}"
    assert_equal random_language, @options[:developer_language]
  end

  def assert_option_encoding
    parse_with '--encoding UTF16'
    assert_equal 'UTF16', @options[:encoding]
  end

  def assert_option_format
    random_format = Twine::Formatters.formatters.sample.format_name.downcase
    parse_with "--format #{random_format}"
    assert_equal random_format, @options[:format]
  end

  def assert_option_include
    random_set = [:all, :translated, :untranslated].sample
    parse_with "--include #{random_set}"
    assert_equal random_set, @options[:include]
  end

  def assert_option_single_language
    random_language = KNOWN_LANGUAGES.sample
    parse_with "--lang #{random_language}"
    assert_equal [random_language], @options[:languages]
  end

  def assert_option_multiple_languages
    random_languages = KNOWN_LANGUAGES.shuffle[0, 3]
    parse_with "--lang #{random_languages.join(',')}"
    assert_equal random_languages.sort, @options[:languages].sort
  end

  def assert_option_languages
    assert_option_single_language
    assert_option_multiple_languages
  end

  def assert_option_output_path
    parse_with "--output-file #{@output_path}"
    assert_equal @output_path, @options[:output_path]  
  end

  def assert_option_quiet
    parse_with '--quiet'
    assert @options[:quiet]
    parse_with '--no-quiet'
    refute @options[:quiet]
  end

  def assert_option_tags
    # single tag
    random_tag = "tag#{rand(100)}"
    parse_with "--tags #{random_tag}"
    assert_equal [[random_tag]], @options[:tags]

    # multiple OR tags
    random_tags = ["tag#{rand(100)}", "tag#{rand(100)}", "tag#{rand(100)}"]
    parse_with "--tags #{random_tags.join(',')}"
    sorted_tags = @options[:tags].map { |tags| tags.sort }
    assert_equal [random_tags.sort], sorted_tags

    # multiple AND tags
    random_tag_1 = "tag#{rand(100)}"
    random_tag_2 = "tag#{rand(100)}"
    parse_with "--tags #{random_tag_1} --tags #{random_tag_2}"
    assert_equal [[random_tag_1], [random_tag_2]], @options[:tags]
    
    # NOT tag
    random_tag = "~tag#{rand(100)}"
    parse_with "--tags #{random_tag}"
    assert_equal [[random_tag]], @options[:tags]
  end

  def assert_option_untagged
    parse_with '--untagged'
    assert @options[:untagged]
    parse_with '--no-untagged'
    refute @options[:untagged]
  end

  def assert_option_validate
    parse_with "--validate"
    assert @options[:validate]
    parse_with "--no-validate"
    refute @options[:validate]
  end
end

class TestCLI < CLITest
  def test_version
    parse "--version"

    assert_equal @options, false
    assert_equal "Twine version #{Twine::VERSION}\n", Twine::stdout.string
  end

  def test_help
    parse ""
    assert_match 'Usage: twine', Twine::stdout.string
  end

  def test_invalid_command
    assert_raises Twine::Error do
      parse "not a command"
    end
  end
end

class TestGenerateLocalizationFileCLI < CLITest
  def parse_with(parameters)
    parse "generate-localization-file #{@twine_file_path} #{@output_path} " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'generate-localization-file', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @output_path, @options[:output_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "generate-localization-file #{@twine_file_path}"
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_developer_language
    assert_option_encoding
    assert_option_format
    assert_option_include
    assert_option_single_language
    assert_raises(Twine::Error) { assert_option_multiple_languages }
    assert_option_quiet
    assert_option_tags
    assert_option_untagged
    assert_option_validate
  end
end

class TestGenerateAllLocalizationFilesCLI < CLITest
  def parse_with(parameters)
    parse "generate-all-localization-files #{@twine_file_path} #{@output_dir} " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'generate-all-localization-files', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @output_dir, @options[:output_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "generate-all-localization-files twine_file"
    end
  end

  def test_extra_arguemnt
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_developer_language
    assert_option_encoding
    assert_option_format
    assert_option_include
    assert_option_quiet
    assert_option_tags
    assert_option_untagged
    assert_option_validate
  end

  def test_option_create_folders
    parse_with '--create-folders'
    assert @options[:create_folders]
    parse_with '--no-create-folders'
    refute @options[:create_folders]
  end

  def test_option_file_name
    random_filename = "#{rand(10000)}"
    parse_with "--file-name #{random_filename}"
    assert_equal random_filename, @options[:file_name]
  end
end

class TestGenerateLocalizationArchiveCLI < CLITest
  def parse_with(parameters)
    parse "generate-localization-archive #{@twine_file_path} #{@output_path} --format apple " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'generate-localization-archive', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @output_path, @options[:output_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "generate-localization-archive twine_file --format apple"
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_developer_language
    assert_option_encoding
    assert_option_include
    assert_option_quiet
    assert_option_tags
    assert_option_untagged
    assert_option_validate
  end

  def test_option_format_required
    assert_raises Twine::Error do
      parse "generate-localization-archive twine_file output"
    end
  end

  def test_supports_deprecated_command
    parse "generate-loc-drop #{@twine_file_path} #{@output_path} --format apple"
    assert_equal 'generate-localization-archive', @options[:command]
  end

  def test_deprecated_command_prints_warning
    parse "generate-loc-drop #{@twine_file_path} #{@output_path} --format apple"
    assert_match "WARNING: Twine commands names have changed.", Twine::stdout.string
  end
end

class TestConsumeLocalizationFileCLI < CLITest
  def parse_with(parameters)
    parse "consume-localization-file #{@twine_file_path} #{@input_path} " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'consume-localization-file', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @input_path, @options[:input_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "consume-localization-file twine_file"
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_consume_all
    assert_option_consume_comments
    assert_option_developer_language
    assert_option_encoding
    assert_option_format
    assert_option_single_language
    assert_raises(Twine::Error) { assert_option_multiple_languages }
    assert_option_output_path
    assert_option_quiet
    assert_option_tags
  end
end

class TestConsumeAllLocalizationFilesCLI < CLITest
  def parse_with(parameters)
    parse "consume-all-localization-files #{@twine_file_path} #{@input_dir} " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'consume-all-localization-files', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @input_dir, @options[:input_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "consume-all-localization-files twine_file"
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_consume_all
    assert_option_consume_comments
    assert_option_developer_language
    assert_option_encoding
    assert_option_format
    assert_option_output_path
    assert_option_quiet
    assert_option_tags
  end
end

class TestConsumeLocalizationArchiveCLI < CLITest
  def parse_with(parameters)
    parse "consume-localization-archive #{@twine_file_path} #{@input_path} " + parameters
  end

  def test_command
    parse_with  ""

    assert_equal 'consume-localization-archive', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
    assert_equal @input_path, @options[:input_path]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse "consume-localization-archive twine_file"
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with "extra"
    end
  end

  def test_options
    assert_help
    assert_option_consume_all
    assert_option_consume_comments
    assert_option_developer_language
    assert_option_encoding
    assert_option_format
    assert_option_output_path
    assert_option_quiet
    assert_option_tags
  end

  def test_supports_deprecated_command
    parse "consume-loc-drop #{@twine_file_path} #{@input_path}"
    assert_equal 'consume-localization-archive', @options[:command]
  end

  def test_deprecated_command_prints_warning
    parse "consume-loc-drop #{@twine_file_path} #{@input_path}"
    assert_match "WARNING: Twine commands names have changed.", Twine::stdout.string
  end
end

class TestValidateTwineFileCLI < CLITest
  def parse_with(parameters)
    parse "validate-twine-file #{@twine_file_path} " + parameters
  end

  def test_command
    parse_with ""

    assert_equal 'validate-twine-file', @options[:command]
    assert_equal @twine_file_path, @options[:twine_file]
  end

  def test_missing_argument
    assert_raises Twine::Error do
      parse 'validate-twine-file'
    end
  end

  def test_extra_argument
    assert_raises Twine::Error do
      parse_with 'extra'
    end
  end

  def test_options
    assert_help
    assert_option_developer_language
    assert_option_quiet
  end

  def test_option_pedantic
    parse "validate-twine-file #{@twine_file_path} --pedantic"
    assert @options[:pedantic]
    parse "validate-twine-file #{@twine_file_path} --no-pedantic"
    refute @options[:pedantic]
  end
end
