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

class TestTwine < TwineTestCase
  # TODO
  # android, apple, django, ... consumption

  def test_consume_string_file_5
    Dir.mktmpdir do |dir|
      # multi line string parsing
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/strings-1.txt test/fixtures/en-2.po -o #{output_path} -l en -a))
      assert_equal(File.read('test/fixtures/test-output-9.txt'), File.read(output_path))
    end
  end

  def test_json_line_breaks_consume
    Dir.mktmpdir do |dir|
      # \n are preserved
      output_path = File.join(dir, 'strings.txt')
      Twine::Runner.run(%W(consume-string-file test/fixtures/test-json-line-breaks/line-breaks.txt test/fixtures/test-json-line-breaks/line-breaks.json -l fr -o #{output_path}))
      assert_equal(File.read('test/fixtures/test-json-line-breaks/consumed.txt'), File.read(output_path))
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
