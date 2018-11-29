require 'command_test'

class TestGenerateLocalizationArchive < CommandTest
  def new_runner(twine_file = nil, options = {})
    options[:output_path] = @output_path
    options[:format] = 'apple'

    unless twine_file
      twine_file = build_twine_file 'en', 'fr' do
        add_section 'Section' do
          add_definition key: 'value'
        end
      end
    end

    Twine::Runner.new(options, twine_file)
  end

  def test_generates_zip_file
    new_runner.generate_localization_archive

    assert File.exist?(@output_path), "zip file should exist"
  end

  def test_zip_file_structure
    new_runner.generate_localization_archive

    names = []
    Zip::File.open(@output_path) do |zipfile|
      zipfile.each do |entry|
        names << entry.name
      end
    end
    assert_equal ['Locales/', 'Locales/en.strings', 'Locales/fr.strings'], names
  end

  def test_uses_formatter
    formatter = prepare_mock_formatter Twine::Formatters::Apple
    formatter.expects(:format_file).twice

    new_runner.generate_localization_archive
  end

  def test_prints_empty_file_warnings
    empty_twine_file = build_twine_file('en') {}
    new_runner(empty_twine_file).generate_localization_archive
    assert_match "Skipping file", Twine::stdout.string
  end

  def test_does_not_print_empty_file_warnings_if_quite
    empty_twine_file = build_twine_file('en') {}
    new_runner(empty_twine_file, quite: true).generate_localization_archive
    refute_match "Skipping file", Twine::stdout.string
  end

  class TestValidate < CommandTest
    def new_runner(validate)
      options = {}
      options[:output_path] = @output_path
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

      new_runner(false).generate_localization_archive
    end

    def test_validates_twine_file_if_validate
      assert_raises Twine::Error do
        new_runner(true).generate_localization_archive
      end
    end
  end
end
