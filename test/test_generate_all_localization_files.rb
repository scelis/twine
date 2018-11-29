require 'command_test'

class TestGenerateAllLocalizationFiles < CommandTest
  def new_runner(create_folders, twine_file = nil, options = {})
    default_options = {}
    default_options[:output_path] = @output_dir
    default_options[:format] = 'apple'
    default_options[:create_folders] = create_folders

    options = default_options.merge options

    unless twine_file
      twine_file = build_twine_file 'en', 'es' do
        add_section 'Section' do
          add_definition key: 'value'
        end
      end
    end

    Twine::Runner.new(options, twine_file)
  end

  class TestFormatterSelection < TestGenerateAllLocalizationFiles
    def setup
      super
      Dir.mkdir File.join @output_dir, 'values-en'
    end

    def new_runner(options = {})
      super(true, nil, options)
    end

    def test_returns_error_for_ambiguous_output_path
      assert_raises Twine::Error do
        new_runner(format: nil).generate_all_localization_files
      end
    end

    def test_uses_specified_formatter_to_resolve_ambiguity
      # implicit assert that this call doesn't raise an exception
      new_runner(format: 'android').generate_all_localization_files
    end
  end

  class TestDoNotCreateFolders < TestGenerateAllLocalizationFiles
    def new_runner(twine_file = nil, options = {})
      super(false, twine_file, options)
    end

    def test_fails_if_output_folder_does_not_exist
      assert_raises Twine::Error do
        new_runner.generate_all_localization_files
      end
    end

    def test_does_not_create_language_folders
      Dir.mkdir File.join @output_dir, 'en.lproj'
      new_runner.generate_all_localization_files
      refute File.exist?(File.join(@output_dir, 'es.lproj')), "language folder should not be created"
    end

    def test_prints_empty_file_warnings
      Dir.mkdir File.join @output_dir, 'en.lproj'
      empty_twine_file = build_twine_file('en') {}
      new_runner(empty_twine_file).generate_all_localization_files
      assert_match "Skipping file at path", Twine::stdout.string
    end

    def test_does_not_print_empty_file_warnings_if_quite
      Dir.mkdir File.join @output_dir, 'en.lproj'
      empty_twine_file = build_twine_file('en') {}
      new_runner(empty_twine_file, quite: true).generate_all_localization_files
      refute_match "Skipping file at path", Twine::stdout.string
    end
  end

  class TestCreateFolders < TestGenerateAllLocalizationFiles
    def new_runner(twine_file = nil, options = {})
      super(true, twine_file, options)
    end

    def test_creates_output_folder
      FileUtils.remove_entry_secure @output_dir
      new_runner.generate_all_localization_files
      assert File.exist? @output_dir
    end

    def test_creates_language_folders
      new_runner.generate_all_localization_files
      assert File.exist?(File.join(@output_dir, 'en.lproj')), "language folder 'en.lproj' should be created"
      assert File.exist?(File.join(@output_dir, 'es.lproj')), "language folder 'es.lproj' should be created"
    end

    def test_prints_empty_file_warnings
      empty_twine_file = build_twine_file('en') {}
      new_runner(empty_twine_file).generate_all_localization_files

      assert_match "Skipping file at path", Twine::stdout.string
    end

    def test_does_not_print_empty_file_warnings_if_quite
      empty_twine_file = build_twine_file('en') {}
      new_runner(empty_twine_file, quite: true).generate_all_localization_files

      refute_match "Skipping file at path", Twine::stdout.string
    end
  end

  class TestValidate < CommandTest
    def new_runner(validate)
      Dir.mkdir File.join @output_dir, 'values-en'

      options = {}
      options[:output_path] = @output_dir
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

      new_runner(false).generate_all_localization_files
    end

    def test_validates_twine_file_if_validate
      assert_raises Twine::Error do
        new_runner(true).generate_all_localization_files
      end
    end
  end
end
