require 'twine_test_case'

class TestGenerateStringFile < TwineTestCase
  def setup
    super

    @known_languages = %w(en fr de sp)

    @mock_strings = Twine::StringsFile.new
    @mock_strings.language_codes.concat @known_languages
    Twine::StringsFile.stubs(:new).returns(@mock_strings)

    @mock_android_formatter = Twine::Formatters::Android.new(@mock_strings, {})
    Twine::Formatters::Android.stubs(:new).returns(@mock_android_formatter)
    @mock_apple_formatter = Twine::Formatters::Apple.new(@mock_strings, {})
    Twine::Formatters::Apple.stubs(:new).returns(@mock_apple_formatter)
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
    options = {
      output_path: File.join(@output_dir, 'fr.strings'),
      languages: ['fr']
    }
    runner = Twine::Runner.new(nil, options)

    @mock_apple_formatter.expects(:write_file)

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

module TwineFileDSL
  def build_twine_file(*languages)
    @currently_built_twine_file = Twine::StringsFile.new
    @currently_built_twine_file.language_codes.concat languages
    yield
    result = @currently_built_twine_file
    @currently_built_twine_file = nil
    return result
  end

  def add_section(name)
    return unless @currently_built_twine_file
    @currently_built_twine_file_section = Twine::StringsSection.new name
    @currently_built_twine_file.sections << @currently_built_twine_file_section
    yield
    @currently_built_twine_file_section = nil
  end

  def add_row(parameters)
    return unless @currently_built_twine_file
    return unless @currently_built_twine_file_section

    language = parameters[:language] || @currently_built_twine_file.language_codes.first

    # this relies on Ruby 1.9 preserving the order of hash elements
    row = Twine::StringsRow.new(parameters.first[0].to_s)
    row.translations[language] = parameters.first[1]
    row.comment = parameters[:comment] if parameters[:comment]

    @currently_built_twine_file_section.rows << row
    @currently_built_twine_file.strings_map[row.key] = row
  end
end

class TestFormatters < TwineTestCase

  include TwineFileDSL

  def setup
    super

    @strings = build_twine_file 'en' do
      add_section 'Section 1' do
        add_row key1: 'key1-english', comment: 'comment key1'
        add_row key2: 'key2-english'
      end

      add_section 'Section 2' do
        add_row key3: 'key3-english'
        add_row key4: 'key4-english', comment: 'comment key4'
      end
    end
  end

  def test_android
    formatter = Twine::Formatters::Android.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_android.xml'), output_content
  end
end

class TestTwine < TwineTestCase

  def test_generate_string_file_2
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.strings')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-1.txt #{output_path} -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-2.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_3
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.json')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-1.txt #{output_path} -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-5.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_4
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.strings')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-2.txt #{output_path} -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-6.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_5
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.po')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-1.txt #{output_path} -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-7.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_6
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-3.txt #{output_path}))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-8.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_7
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-2.txt #{output_path} -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-10.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_8
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'fr.xml')
      Twine::Runner.run(%W(generate-string-file --format tizen test/fixtures/strings-1.txt #{output_path}))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-12.txt')).result, File.read(output_path))
    end
  end

  def test_include_translated
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'fr.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-1.txt #{output_path} --include translated))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-13.txt')).result, File.read(output_path))
    end
  end

  def test_consume_string_file_1
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/fr-1.xml -o #{output_path} -l fr))
      assert_equal(File.read('test/fixtures/test-output-3.txt'), File.read(output_path))
    end
  end

  def test_consume_string_file_2
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/en-1.strings -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-4.txt'), File.read(output_path))
    end
  end

  def test_consume_string_file_3
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/en-1.json -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-4.txt'), File.read(output_path))
    end
  end

  def test_consume_string_file_4
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/en-1.po -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-4.txt'), File.read(output_path))
    end
  end

  def test_consume_string_file_5
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/en-2.po -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-9.txt'), File.read(output_path))
    end
  end

  def test_consume_string_file_6
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-2.txt test/fixtures/en-3.xml -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-11.txt'), File.read(output_path))
    end
  end

  def test_json_line_breaks_consume
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/test-json-line-breaks/line-breaks.txt test/fixtures/test-json-line-breaks/line-breaks.json -l fr -o #{output_path}))
      assert_equal(File.read('test/fixtures/test-json-line-breaks/consumed.txt'), File.read(output_path))
    end
  end

  def test_json_line_breaks_generate
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'en.json')
      Twine::Runner.run(%W(generate-string-file test/fixtures/test-json-line-breaks/line-breaks.txt #{output_path}))
      assert_equal(File.read('test/fixtures/test-json-line-breaks/generated.json'), File.read(output_path))
    end
  end

  def test_generate_string_file_14_include_untranslated
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'include_untranslated.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-1.txt #{output_path} --include untranslated -l fr))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-14.txt')).result, File.read(output_path))
    end
  end

  def test_generate_string_file_14_references
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'references.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-4-references.txt #{output_path} -l fr -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-14-references.txt')).result, File.read(output_path))
    end
  end  
end
