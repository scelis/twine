require 'twine_test_case'

class TestTwineFile < TwineTestCase
  class Reading < TwineTestCase
    def setup
      super

      @twine_file = Twine::TwineFile.new
      @twine_file.read fixture_path('twine_accent_values.txt')
    end

    def test_reading_keeps_leading_accent
      assert_equal '`value', @twine_file.definitions_by_key['value_with_leading_accent'].translations['en']
    end

    def test_reading_keeps_trailing_accent
      assert_equal 'value`', @twine_file.definitions_by_key['value_with_trailing_accent'].translations['en']
    end

    def test_reading_keeps_leading_space
      assert_equal ' value', @twine_file.definitions_by_key['value_with_leading_space'].translations['en']
    end

    def test_reading_keeps_trailing_space
      assert_equal 'value ', @twine_file.definitions_by_key['value_with_trailing_space'].translations['en']
    end

    def test_reading_keeps_wrapping_spaces
      assert_equal ' value ', @twine_file.definitions_by_key['value_wrapped_by_spaces'].translations['en']
    end

    def test_reading_keeps_wrapping_accents
      assert_equal '`value`', @twine_file.definitions_by_key['value_wrapped_by_accents'].translations['en']
    end
  end

  class Writing < TwineTestCase

    def test_accent_wrapping
      @twine_file = build_twine_file 'en' do
        add_section 'Section' do
          add_definition value_with_leading_accent: '`value'
          add_definition value_with_trailing_accent: 'value`'
          add_definition value_with_leading_space: ' value'
          add_definition value_with_trailing_space: 'value '
          add_definition value_wrapped_by_spaces: ' value '
          add_definition value_wrapped_by_accents: '`value`'
        end
      end

      @twine_file.write @output_path

      assert_equal content('twine_accent_values.txt'), File.read(@output_path)
    end

  end

end
