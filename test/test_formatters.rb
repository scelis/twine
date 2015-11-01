require 'twine_test_case'

class FormatterTest < TwineTestCase

  def setup
    super

    @strings = build_twine_file 'en' do
      add_section 'Section 1' do
        add_row key1: 'value1-english', comment: 'comment key1'
        add_row key2: 'value2-english'
      end

      add_section 'Section 2' do
        add_row key3: 'value3-english'
        add_row key4: 'value4-english', comment: 'comment key4'
      end
    end
  end

end

class TestAndroidFormatter < FormatterTest
  # TODO
  #   quote escaping
  #   html entity escaping
  #   placeholders

  def test_android_format
    formatter = Twine::Formatters::Android.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_android.xml'), output_content
  end

end

class TestAppleFormatter < FormatterTest

  def test_apple_format
    formatter = Twine::Formatters::Apple.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_apple.strings'), output_content
  end

end

class TestJQueryFormatter < FormatterTest

  def test_jquery_format
    formatter = Twine::Formatters::JQuery.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_jquery.json'), output_content
  end

end
