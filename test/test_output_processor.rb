require 'twine_test_case'

class TestOutputProcessor < TwineTestCase
  def setup
    super

    @strings = build_twine_file 'en', 'fr' do
      add_section 'Section 1' do
        add_row key1: 'value1', tags: ['tag1']
        add_row key2: 'value2', tags: ['tag1', 'tag2']
        add_row key3: 'value3', tags: ['tag2']
        add_row key4: { en: 'value4-en', fr: 'value4-fr' }
      end
    end
  end

  def test_includes_all_keys_by_default
    processor = Twine::Processors::OutputProcessor.new(@strings, {})
    result = processor.process('en')

    assert_equal %w(key1 key2 key3 key4), result.strings_map.keys.sort
  end

  def test_filter_by_tag
    processor = Twine::Processors::OutputProcessor.new(@strings, { tags: ['tag1'] })
    result = processor.process('en')

    assert_equal %w(key1 key2), result.strings_map.keys.sort
  end

  def test_filter_by_multiple_tags
    processor = Twine::Processors::OutputProcessor.new(@strings, { tags: ['tag1', 'tag2'] })
    result = processor.process('en')

    assert_equal %w(key1 key2 key3), result.strings_map.keys.sort
  end

  def test_filter_untagged
    processor = Twine::Processors::OutputProcessor.new(@strings, { tags: ['tag1'], untagged: true })
    result = processor.process('en')

    assert_equal %w(key1 key2 key4), result.strings_map.keys.sort
  end

  def test_include_translated
    processor = Twine::Processors::OutputProcessor.new(@strings, { include: 'translated' })
    result = processor.process('fr')

    assert_equal %w(key4), result.strings_map.keys.sort
  end
end
