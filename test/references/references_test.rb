require 'erb'
require 'rubygems'
require 'test/unit'
require 'twine'

class TwineTest < Test::Unit::TestCase
  def setup
    super
    @output_dir = Dir.mktmpdir
    @output_path = File.join @output_dir, SecureRandom.uuid
  end

  def teardown
    FileUtils.remove_entry_secure @output_dir
    super
  end

  def output_content
    File.read @output_path
  end

  def execute(command)
    command += "  -o #{@output_path}"
    Twine::Runner.run(command.split(" "))
  end

  def fixture(filename)
    "test/references/fixtures/#{filename}"
  end
  alias :f :fixture

  def content(filename)
    File.read fixture(filename)
  end
end

class ReferencesTest < TwineTest
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
