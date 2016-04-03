require 'twine_test_case'

class TestAbstractFormatter < TwineTestCase
  class SetTranslation < TwineTestCase
    def setup
      super

      @twine_file = build_twine_file 'en', 'fr' do
        add_section 'Section' do
          add_definition key1: 'value1-english'
          add_definition key2: { en: 'value2-english', fr: 'value2-french' }
        end
      end

      @formatter = Twine::Formatters::Abstract.new
      @formatter.twine_file = @twine_file
    end

    def test_set_translation_updates_existing_value
      @formatter.set_translation_for_key 'key1', 'en', 'value1-english-updated'

      assert_equal 'value1-english-updated', @twine_file.definitions_by_key['key1'].translations['en']
    end

    def test_set_translation_does_not_alter_other_language
      @formatter.set_translation_for_key 'key2', 'en', 'value2-english-updated'

      assert_equal 'value2-french', @twine_file.definitions_by_key['key2'].translations['fr']
    end

    def test_set_translation_escapes_newlines
      @formatter.set_translation_for_key 'key1', 'en', "new\nline"

      assert_equal 'new\nline', @twine_file.definitions_by_key['key1'].translations['en']
    end

    def test_set_translation_adds_translation_to_existing_key
      @formatter.set_translation_for_key 'key1', 'fr', 'value1-french'

      assert_equal 'value1-french', @twine_file.definitions_by_key['key1'].translations['fr']
    end

    def test_set_translation_does_not_add_new_key
      @formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

      assert_nil @twine_file.definitions_by_key['new-key']
    end

    def test_set_translation_consume_all_adds_new_key
      formatter = Twine::Formatters::Abstract.new
      formatter.twine_file = @twine_file
      formatter.options = { consume_all: true }
      formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

      assert_equal 'new-key-english', @twine_file.definitions_by_key['new-key'].translations['en']
    end

    def test_set_translation_consume_all_adds_tags
      random_tag = SecureRandom.uuid
      formatter = Twine::Formatters::Abstract.new
      formatter.twine_file = @twine_file
      formatter.options = { consume_all: true, tags: [random_tag] }
      formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

      assert_equal [random_tag], @twine_file.definitions_by_key['new-key'].tags
    end

    def test_set_translation_adds_new_keys_to_category_uncategoriezed
      formatter = Twine::Formatters::Abstract.new
      formatter.twine_file = @twine_file
      formatter.options = { consume_all: true }
      formatter.set_translation_for_key 'new-key', 'en', 'new-key-english'

      assert_equal 'Uncategorized', @twine_file.sections[0].name 
      assert_equal 'new-key', @twine_file.sections[0].definitions[0].key
    end
  end

  class ValueReference < TwineTestCase
    def setup
      super

      @twine_file = build_twine_file 'en', 'fr' do
        add_section 'Section' do
          add_definition refkey: 'ref-value'
          add_definition key: :refkey
        end
      end

      @formatter = Twine::Formatters::Abstract.new
      @formatter.twine_file = @twine_file
    end

    def test_set_translation_does_not_add_unchanged_translation
      @formatter.set_translation_for_key 'key', 'en', 'ref-value'

      assert_nil @twine_file.definitions_by_key['key'].translations['en']
    end

    def test_set_translation_adds_changed_translation
      @formatter.set_translation_for_key 'key', 'en', 'changed value'

      assert_equal 'changed value', @twine_file.definitions_by_key['key'].translations['en']
    end
  end

  class SetComment < TwineTestCase
    def setup
      super

      @twine_file = build_twine_file 'en' do
        add_section 'Section' do
          add_definition key: 'value'
        end
      end
    end

    def test_set_comment_for_key_does_not_update_comment
      formatter = Twine::Formatters::Abstract.new
      formatter.twine_file = @twine_file
      formatter.set_comment_for_key('key', 'comment')

      assert_nil formatter.twine_file.definitions_by_key['key'].comment
    end

    def test_set_comment_for_key_updates_comment_with_update_comments
      formatter = Twine::Formatters::Abstract.new
      formatter.twine_file = @twine_file
      formatter.options = { consume_comments: true }
      formatter.set_comment_for_key('key', 'comment')

      assert_equal 'comment', formatter.twine_file.definitions_by_key['key'].comment
    end
  end

  class CommentReference < TwineTestCase
    def setup
      super

      @twine_file = build_twine_file 'en' do
        add_section 'Section' do
          add_definition refkey: 'ref-value', comment: 'reference comment'
          add_definition key: 'value', ref: :refkey
        end
      end

      @formatter = Twine::Formatters::Abstract.new
      @formatter.twine_file = @twine_file
      @formatter.options = { consume_comments: true }
    end

    def test_set_comment_does_not_add_unchanged_comment
      @formatter.set_comment_for_key 'key', 'reference comment'
      
      assert_nil @twine_file.definitions_by_key['key'].raw_comment
    end

    def test_set_comment_adds_changed_comment
      @formatter.set_comment_for_key 'key', 'changed comment'

      assert_equal 'changed comment', @twine_file.definitions_by_key['key'].raw_comment
    end
  end

end
