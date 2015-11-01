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

  def setup
    super
    @formatter = Twine::Formatters::Android.new @strings, {}
  end

  def test_format
    @formatter.write_file @output_path, 'en'
    assert_equal content('formatter_android.xml'), output_content
  end

  def test_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_value_with_trailing_space
    assert_equal "\\u0020value", @formatter.format_value(' value')
  end

  def test_value_with_trailing_space
    assert_equal "value\\u0020", @formatter.format_value('value ')
  end

end

class TestAppleFormatter < FormatterTest

  def test_format
    formatter = Twine::Formatters::Apple.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_apple.strings'), output_content
  end

end

class TestJQueryFormatter < FormatterTest

  def test_format
    formatter = Twine::Formatters::JQuery.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_jquery.json'), output_content
  end

end

class TestGettextFormatter < FormatterTest

  def test_format
    formatter = Twine::Formatters::Gettext.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_gettext.po'), output_content
  end

end
