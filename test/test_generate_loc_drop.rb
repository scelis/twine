require 'command_test_case'

class TestGenerateLocDrop < CommandTestCase
  def setup
    super

    options = {}
    options[:output_path] = @output_path
    options[:format] = 'apple'

    @twine_file = build_twine_file 'en', 'fr' do
      add_section 'Section' do
        add_row key: 'value'
      end
    end

    @runner = Twine::Runner.new(options, @twine_file)
  end

  def test_generates_zip_file
    @runner.generate_loc_drop

    assert File.exists?(@output_path), "language folder should not be created"
  end

  def test_zip_file_structure
    @runner.generate_loc_drop

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
    formatter.expects(:write_file).twice.with() { |path, lang| FileUtils.touch path }

    @runner.generate_loc_drop
  end
end
