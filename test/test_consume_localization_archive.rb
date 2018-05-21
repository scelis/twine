require 'command_test'

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
    options[:input_path] = fixture_path 'consume_localization_archive.zip'
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
end
