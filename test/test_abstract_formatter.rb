require 'twine_test_case'

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
    skip 'not supported by current implementation - see #97'
  end

  def test_set_comment_for_key_updates_comment_with_update_comments
    skip 'not supported by current implementation - see #97'
  end
end
