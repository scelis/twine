require 'twine_test_case'

class TestTwineDefinition < TwineTestCase
  def setup
    super

    @reference = Twine::TwineDefinition.new 'reference-key'
    @reference.comment = 'reference comment'
    @reference.tags = ['ref1']
    @reference.translations['en'] = 'ref-value'

    @definition = Twine::TwineDefinition.new 'key'
    @definition.reference_key = @reference.key
    @definition.reference = @reference
  end

  def test_reference_comment_used
    assert_equal 'reference comment', @definition.comment
  end

  def test_reference_comment_override
    @definition.comment = 'definition comment'

    assert_equal 'definition comment', @definition.comment
  end

  def test_reference_tags_used
    assert @definition.matches_tags?(['ref1'], false)
  end

  def test_reference_tags_override
    @definition.tags = ['tag1']

    refute @definition.matches_tags?(['ref1'], false)
    assert @definition.matches_tags?(['tag1'], false)
  end

  def test_reference_translation_used
    assert_equal 'ref-value', @definition.translated_string_for_lang('en')
  end

  def test_reference_translation_override
    @definition.translations['en'] = 'value'

    assert_equal 'value', @definition.translated_string_for_lang('en')
  end
end
