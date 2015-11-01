require 'twine_test_case'

class TestFormatters < TwineTestCase
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

  def test_android
    formatter = Twine::Formatters::Android.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_android.xml'), output_content
  end

  def test_apple
    formatter = Twine::Formatters::Apple.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_apple.strings'), output_content
  end

  def test_jquery
    formatter = Twine::Formatters::JQuery.new @strings, {}
    formatter.write_file @output_path, 'en'
    assert_equal content('formatter_jquery.json'), output_content
  end
end
