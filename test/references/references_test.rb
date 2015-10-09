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
    super
    FileUtils.remove_entry_secure @output_dir
  end

  def output_content
    File.read @output_path
  end

  def execute(command)
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
    execute "consume-string-file #{f input} #{f 'empty.xml'} -o #{@output_path} -l en"
    assert_equal content(input), output_content
  end

  def test_consuption_does_not_add_comment
    input = 'twine_comment_reference.txt'
    execute "consume-string-file #{f input} #{f 'empty.xml'} -o #{@output_path} -l en"
    assert_equal content(input), output_content
  end

  def test_consumption_does_not_add_tags
    input = 'twine_tag_reference.txt'
    execute "consume-string-file #{f input} #{f 'empty.xml'} -o #{@output_path} -l en"
    assert_equal content(input), output_content
  end

  def test_consumption_does_not_add_unchanged_translation
    original = 'twine_value_reference.txt'
    FileUtils.copy fixture(original), @output_path

    execute "consume-string-file #{@output_path} #{f 'same_value.xml'} -o #{@output_path} -l en"
    assert_equal content(original), output_content
  end

  def test_consumption_adds_changed_translation
    FileUtils.copy fixture('twine_value_reference.txt'), @output_path

    execute "consume-string-file #{@output_path} #{f 'different_value.xml'} -o #{@output_path} -l en"
    assert_equal content('twine_updated_value.txt'), output_content
  end

  # TODO: update/keep comments
  # TODO: update/keep
end
