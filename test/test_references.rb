require 'twine_test_case'

class TestReferences < TwineTestCase
  def fixture_path
    'fixtures/references'
  end

  def test_consumption_preserves_references
    input = 'twine_value_reference.txt'
    execute "consume-string-file #{f input} #{f 'empty.xml'} -l en"
    assert_equal content(input), output_content
  end

  def test_consumption_does_not_add_unchanged_translation
    input = 'twine_value_reference.txt'
    execute "consume-string-file #{f input} #{f 'same_value.xml'} -l en"
    assert_equal content(input), output_content
  end

  def test_consumption_adds_changed_translation
    execute "consume-string-file #{f 'twine_value_reference.txt'} #{f 'different_value.xml'} -l en"
    assert_equal content('twine_updated_value.txt'), output_content
  end

  def test_consuption_does_not_add_comment
    input = 'twine_comment_reference.txt'
    execute "consume-string-file #{f input} #{f 'empty.xml'} -l en"
    assert_equal content(input), output_content
  end

  def test_consumption_does_not_add_unchanged_comment
    input = 'twine_comment_reference.txt'
    execute "consume-string-file #{f input} #{f 'same_comment.xml'} -l en -c"
    assert_equal content(input), output_content
  end

  def test_consumption_adds_changed_comment
    execute "consume-string-file #{f 'twine_comment_reference.txt'} #{f 'different_comment.xml'} -l en -c"
    assert_equal content('twine_updated_comment.txt'), output_content
  end

  def test_consumption_does_not_add_tags
    input = 'twine_tag_reference.txt'
    execute "consume-string-file #{f input} #{f 'empty.xml'} -l en -c"
    assert_equal content(input), output_content
  end
end
