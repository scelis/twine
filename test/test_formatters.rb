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
  #   strings starting with an @  

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

  def test_value_with_leading_space
    assert_equal "\\u0020value", @formatter.format_value(' value')
  end

  def test_value_with_trailing_space
    assert_equal "value\\u0020", @formatter.format_value('value ')
  end

  def test_escapes_single_quotes
    skip
    # TODO: not working with ruby 2.0
    # http://stackoverflow.com/questions/18735608/cgiescapehtml-is-escaping-single-quote
    assert_equal "not \\'so\\' easy", @formatter.format_value("not 'so' easy")
  end

  def test_transforms_string_placeholder
    assert_equal '%s', @formatter.format_value('%@')
  end

  def test_transforms_ordered_string_placeholder
    assert_equal '%1s', @formatter.format_value('%1@')
  end

  def test_transforming_ordered_placeholders_maintains_order
    assert_equal '%2s %1d', @formatter.format_value('%2@ %1d')
  end

  def test_does_not_alter_double_percent
    assert_equal '%%d%%', @formatter.format_value('%%d%%')
  end

end

class TestAppleFormatter < FormatterTest
  def setup
    super

    @formatter = Twine::Formatters::Apple.new @strings, {}
  end

  def test_format
    @formatter.write_file @output_path, 'en'
    assert_equal content('formatter_apple.strings'), output_content
  end

  def test_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_value_with_leading_space
    assert_equal ' value', @formatter.format_value(' value')
  end

  def test_value_with_trailing_space
    assert_equal 'value ', @formatter.format_value('value ')
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

class TestTizenFormatter < FormatterTest

  def test_format
    formatter = Twine::Formatters::Tizen.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_tizen.xml'), output_content
  end

end
