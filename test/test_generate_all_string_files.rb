require 'command_test_case'

class TestGenerateAllStringFiles < CommandTestCase
  class TestCreateFolders < CommandTestCase
    def new_runner(create_folders)
      options = {}
      options[:output_path] = @output_dir
      options[:format] = 'apple'
      options[:create_folders] = create_folders

      twine_file = build_twine_file 'en', 'es' do
        add_section 'Section' do
          add_row key: 'value'
        end
      end

      Twine::Runner.new(options, twine_file)
    end

    def test_fails_if_output_folder_does_not_exist
      assert_raises Twine::Error do
        new_runner(false).generate_all_string_files
      end
    end

    def test_creates_output_folder
      FileUtils.remove_entry_secure @output_dir
      new_runner(true).generate_all_string_files
      assert File.exists? @output_dir
    end

    def test_does_not_create_language_folders_by_default
      Dir.mkdir File.join @output_dir, 'en.lproj'
      new_runner(false).generate_all_string_files
      refute File.exists?(File.join(@output_dir, 'es.lproj')), "language folder should not be created"
    end

    def test_creates_language_folders
      new_runner(true).generate_all_string_files
      assert File.exists?(File.join(@output_dir, 'en.lproj')), "language folder 'en.lproj' should be created"
      assert File.exists?(File.join(@output_dir, 'es.lproj')), "language folder 'es.lproj' should be created"
    end
  end

  class TestDeliberate < CommandTestCase
    def new_runner(validate)
      Dir.mkdir File.join @output_dir, 'values-en'

      options = {}
      options[:output_path] = @output_dir
      options[:format] = 'android'
      options[:validate] = validate

      twine_file = build_twine_file 'en' do
        add_section 'Section' do
          add_row key: 'value'
          add_row key: 'value'
        end
      end

      Twine::Runner.new(options, twine_file)
    end

    def test_does_not_validate_strings_file
      prepare_mock_formatter Twine::Formatters::Android

      new_runner(false).generate_all_string_files
    end

    def test_validates_strings_file_if_validate
      assert_raises Twine::Error do
        new_runner(true).generate_all_string_files
      end
    end
  end
end
