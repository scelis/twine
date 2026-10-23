require 'command_test'
require 'zip'

class TestConsumeLocalizationArchive < CommandTest
  def setup
    super

    @twine_file = build_twine_file 'en', 'es' do
      add_section 'Section' do
        add_definition key1: 'value1'
      end
    end
  end

  def new_runner(options = {})
    options[:input_path] ||= fixture_path 'consume_localization_archive.zip'
    options[:output_path] = @output_path

    Twine::Runner.new(options, @twine_file)
  end

  def test_consumes_zip_file
    new_runner(format: 'android').consume_localization_archive

    assert @twine_file.definitions_by_key['key1'].translations['en'], 'value1-english'
    assert @twine_file.definitions_by_key['key1'].translations['es'], 'value1-spanish'
  end

  def test_raises_error_if_format_ambiguous
    assert_raises Twine::Error do
      new_runner.consume_localization_archive
    end
  end

  def test_skips_entries_outside_of_extraction_directory
    extract_dir = File.join(@output_dir, 'extract')
    Dir.mkdir extract_dir
    Dir.stubs(:mktmpdir).yields(extract_dir)

    archive_path = File.join(@output_dir, 'unsafe.zip')
    Zip::OutputStream.open(archive_path) do |zip|
      zip.put_next_entry('../escaped/en.xml')
      zip.write '<resources><string name="key1">value1-english</string></resources>'
    end

    assert_raises Twine::Error do
      new_runner(input_path: archive_path, format: 'android').consume_localization_archive
    end

    refute File.exist?(File.join(@output_dir, 'escaped')), 'archive entry was written outside of the extraction directory'
    assert_match 'Skipping unsafe archive entry: ../escaped/en.xml', Twine::stderr.string
  end
end
