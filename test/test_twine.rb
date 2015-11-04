require 'twine_test_case'

# TODO:
# twine file
#   reading twine files
#     remove wrapping accents
#   writing twine files
#     add accents around values with leading space
#     add accents around values with trailing space
#     add accents around values wrapped in accents
# fallback to developer language

class TestAbstractFormatter < TwineTestCase
  def setup
    super

    @strings = build_twine_file 'en', 'fr' do
      add_section 'Section' do
        add_row key1: 'value1-english'
        add_row key2: { en: 'value2-english', fr: 'value2-french' }
      end
    end

    @formatter = Twine::Formatters::Abstract.new(@strings, {})
  end

  def test_set_translation_updates_existing_value
    @formatter.set_translation_for_key 'key1', 'en', 'value1-english-updated'

    assert_equal 'value1-english-updated', @strings.strings_map['key1'].translations['en']
  end

  def test_set_translation_does_not_alter_other_language
    @formatter.set_translation_for_key 'key2', 'en', 'value2-english-updated'

    assert_equal 'value2-french', @strings.strings_map['key2'].translations['fr']
  end

  def test_set_translation_adds_translation_to_existing_key
    @formatter.set_translation_for_key 'key1', 'fr', 'value1-french'

    assert_equal 'value1-french', @strings.strings_map['key1'].translations['fr']
  end

  def test_set_translation_does_not_add_new_key
    @formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

    assert_nil @strings.strings_map['new-key']
  end

  def test_set_translation_consume_all_adds_new_key
    formatter = Twine::Formatters::Abstract.new(@strings, { consume_all: true })
    formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

    assert_equal 'new-key-english', @strings.strings_map['new-key'].translations['en']
  end

  def test_set_translation_consume_all_adds_tags
    random_tag = SecureRandom.uuid
    formatter = Twine::Formatters::Abstract.new(@strings, { consume_all: true, tags: [random_tag] })
    formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

    assert_equal [random_tag], @strings.strings_map['new-key'].tags
  end

  def test_set_translation_adds_new_keys_to_category_uncategoriezed
    formatter = Twine::Formatters::Abstract.new(@strings, { consume_all: true })
    formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

    assert_equal 'Uncategorized', @strings.sections[0].name 
    assert_equal 'new-key', @strings.sections[0].rows[0].key
  end

  def test_set_comment_for_key_does_not_update_comment
    # not supported by current implementation - see #97
    skip
  end

  def test_set_comment_for_key_updates_comment_with_update_comments
    # not supported by current implementation - see #97
    skip
  end
end

class TestTwine < TwineTestCase

  def test_consume_string_file_1
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'strings.txt')
      # TODO: think about consume option handling/tests
        # maybe: manually feed translations to Abstract formatter

      # android, apple, django, ... consumption

      # consume updates existing translations
      # consume leaves other translations untouched -> add_row key3: { en: 'key3-english', fr: 'key3-french' }
      # consume deducts language
      # consume deducts format (android, apple)

      # consume does not add new translations
      # consume adds new translations when -a is specified
      # updates does not update comments
      # updates comments when -c is used

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

  def test_generate_string_file_14_references
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'references.xml')
      Twine::Runner.run(%W(generate-string-file test/fixtures/strings-4-references.txt #{output_path} -l fr -t tag1))
      assert_equal(ERB.new(File.read('test/fixtures/test-output-14-references.txt')).result, File.read(output_path))
    end
  end  
end
