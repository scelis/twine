require 'twine_test'

class FormatterTest < TwineTest
  def setup(formatter_class)
    super()

    @twine_file = build_twine_file 'en' do
      add_section 'Section 1' do
        add_definition key1: 'value1-english', comment: 'comment key1'
        add_definition key2: 'value2-english'
      end

      add_section 'Section 2' do
        add_definition key3: 'value3-english'
        add_definition key4: 'value4-english', comment: 'comment key4'
      end
    end

    @empty_twine_file = Twine::TwineFile.new
    @formatter = formatter_class.new
    @formatter.twine_file = @empty_twine_file
    @formatter.options = { consume_all: true, consume_comments: true }
  end

  def assert_translations_read_correctly
    1.upto(4) do |i|
      assert_equal "value#{i}-english", @empty_twine_file.definitions_by_key["key#{i}"].translations['en']
    end
  end

  def assert_file_contents_read_correctly
    assert_translations_read_correctly

    assert_equal "comment key1", @empty_twine_file.definitions_by_key["key1"].comment
    assert_equal "comment key4", @empty_twine_file.definitions_by_key["key4"].comment
  end
end

class TestAndroidFormatter < FormatterTest
  def setup
    super Twine::Formatters::Android

    @escape_test_values = {
      'this & that'               => 'this &amp; that',
      'this < that'               => 'this &lt; that',
      "it's complicated"          => "it\\'s complicated",
      'a "good" way'              => 'a \"good\" way',

      '<b>bold</b>'               => '<b>bold</b>',
      '<i>italic</i>'             => '<i>italic</i>',
      '<u>underline</u>'          => '<u>underline</u>',

      '<b>%@</b>'                 => '&lt;b>%s&lt;/b>',
      '<i>%@</i>'                 => '&lt;i>%s&lt;/i>',
      '<u>%@</u>'                 => '&lt;u>%s&lt;/u>',

      '<span>inline</span>'       => '&lt;span>inline&lt;/span>',
      '<p>paragraph</p>'          => '&lt;p>paragraph&lt;/p>',

      '<a href="target">link</a>'     => '<a href="target">link</a>',
      '<a href="target">"link"</a>'   => '<a href="target">\"link\"</a>',
      '<a href="target"></a>"out"'    => '<a href="target"></a>\"out\"',
      '<a href="http://url.com?param=1&param2=3&param3=%20">link</a>'   =>   '<a href="http://url.com?param=1&param2=3&param3=%20">link</a>',

      '<p>escaped</p><![CDATA[]]>'                => '&lt;p>escaped&lt;/p><![CDATA[]]>',
      '<![CDATA[]]><p>escaped</p>'                => '<![CDATA[]]>&lt;p>escaped&lt;/p>',
      '<![CDATA[<p>unescaped</p>]]>'              => '<![CDATA[<p>unescaped</p>]]>',
      '<![CDATA[<p>unescaped with %@</p>]]>'      => '<![CDATA[<p>unescaped with %s</p>]]>',
      '<![CDATA[]]><![CDATA[<p>unescaped</p>]]>'  => '<![CDATA[]]><![CDATA[<p>unescaped</p>]]>',

      '<![CDATA[&]]>'  => '<![CDATA[&]]>',
      '<![CDATA[\']]>' => '<![CDATA[\']]>',
      '<![CDATA["]]>'  => '<![CDATA["]]>',

      '<xliff:g></xliff:g>' => '<xliff:g></xliff:g>',
      '<xliff:g>untouched</xliff:g>' => '<xliff:g>untouched</xliff:g>',
      '<xliff:g id="42">untouched</xliff:g>' => '<xliff:g id="42">untouched</xliff:g>',
      '<xliff:g id="1">first</xliff:g> inbetween <xliff:g id="2">second</xliff:g>' => '<xliff:g id="1">first</xliff:g> inbetween <xliff:g id="2">second</xliff:g>'
    }
  end

  def test_read_format
    @formatter.read content_io('formatter_android.xml'), 'en'

    assert_file_contents_read_correctly
  end

  def test_read_multiline_translation
    content = <<-EOCONTENT
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="foo">This is
     a string</string>
      </resources>
    EOCONTENT

    io = StringIO.new(content)

    @formatter.read io, 'en'

    assert_equal 'This is\n a string', @empty_twine_file.definitions_by_key["foo"].translations['en']
  end

  def test_read_html_tags
    content = <<-EOCONTENT
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="foo">Hello, <b>BOLD</b></string>
      </resources>
    EOCONTENT

    io = StringIO.new(content)

    @formatter.read io, 'en'

    assert_equal 'Hello, <b>BOLD</b>', @empty_twine_file.definitions_by_key["foo"].translations['en']
  end

  def test_double_quotes_are_not_modified
    content = <<-EOCONTENT
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
        <string name="foo">Hello, <a href="http://www.foo.com">BOLD</a></string>
      </resources>
    EOCONTENT

    io = StringIO.new(content)

    @formatter.read io, 'en'

    assert_equal 'Hello, <a href="http://www.foo.com">BOLD</a>', @empty_twine_file.definitions_by_key["foo"].translations['en']
  end

  def test_set_translation_converts_leading_spaces
    @formatter.set_translation_for_key 'key1', 'en', "\u0020value"
    assert_equal ' value', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_set_translation_coverts_trailing_spaces
    @formatter.set_translation_for_key 'key1', 'en', "value\u0020\u0020"
    assert_equal 'value  ', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_set_translation_converts_string_placeholders
    @formatter.set_translation_for_key 'key1', 'en', "value %s"
    assert_equal 'value %@', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_set_translation_unescapes_at_signs
    @formatter.set_translation_for_key 'key1', 'en', '\@value'
    assert_equal '@value', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_set_translation_unescaping
    @escape_test_values.each do |expected, input|
      @formatter.set_translation_for_key 'key1', 'en', input
      assert_equal expected, @empty_twine_file.definitions_by_key['key1'].translations['en']
    end
  end

  def test_format_file
    formatter = Twine::Formatters::Android.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_android.xml'), formatter.format_file('en')
  end

  def test_format_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_format_value_with_leading_space
    assert_equal "\\u0020value", @formatter.format_value(' value')
  end

  def test_format_value_with_trailing_space
    assert_equal "value\\u0020", @formatter.format_value('value ')
  end

  def test_format_value_string_placeholder
    assert_equal "The file %s could not be found.", @formatter.format_value("The file %@ could not be found.")
  end

  def test_format_value_escaping
    @escape_test_values.each do |input, expected|
      assert_equal expected, @formatter.format_value(input)
    end
  end

  def test_format_value_escapes_non_resource_identifier_at_signs
    assert_equal '\@whatever  \@\@', @formatter.format_value('@whatever  @@')
  end

  def test_format_value_does_not_modify_resource_identifiers
    identifier = '@android:string/cancel'
    assert_equal identifier, @formatter.format_value(identifier)
  end

  def test_deducts_language_from_filename
    language = KNOWN_LANGUAGES.sample
    assert_equal language, @formatter.determine_language_given_path("#{language}.xml")
  end

  def test_recognize_every_twine_language_from_filename
    twine_file = build_twine_file "not-a-lang-code" do
      add_section "Section" do
        add_definition key: "value"
      end
    end

    @formatter.twine_file = twine_file
    assert_equal "not-a-lang-code", @formatter.determine_language_given_path("not-a-lang-code.xml")
  end

  def test_deducts_language_from_resource_folder
    language = KNOWN_LANGUAGES.sample
    assert_equal language, @formatter.determine_language_given_path("res/values-#{language}")
  end

  def test_deducts_language_and_region_from_resource_folder
    assert_equal 'de-AT', @formatter.determine_language_given_path("res/values-de-rAT")
  end

  def test_does_not_deduct_language_from_device_capability_resource_folder
    assert_nil @formatter.determine_language_given_path('res/values-w820dp')
  end

  def test_output_path_is_prefixed
    assert_equal 'values-en', @formatter.output_path_for_language('en')
  end

  def test_output_path_with_region
    assert_equal 'values-en-rGB', @formatter.output_path_for_language('en-GB')
  end
end

class TestAppleFormatter < FormatterTest
  def setup
    super Twine::Formatters::Apple
  end

  def test_read_format
    @formatter.read content_io('formatter_apple.strings'), 'en'

    assert_file_contents_read_correctly
  end

  def test_deducts_language_from_filename
    language = KNOWN_LANGUAGES.sample
    assert_equal language, @formatter.determine_language_given_path("#{language}.strings")
  end

  def test_recognize_every_twine_language_from_filename
    twine_file = build_twine_file "not-a-lang-code" do
      add_section "Section" do
        add_definition key: "value"
      end
    end

    @formatter.twine_file = twine_file
    assert_equal "not-a-lang-code", @formatter.determine_language_given_path("not-a-lang-code.strings")
  end

  def test_deducts_language_from_resource_folder
    language = %w(en de fr).sample
    assert_equal language, @formatter.determine_language_given_path("#{language}.lproj/Localizable.strings")
  end

  def test_deducts_base_language_from_resource_folder
    @formatter.options = { consume_all: true, consume_comments: true, developer_language: 'en' }
    assert_equal 'en', @formatter.determine_language_given_path('Base.lproj/Localizations.strings')
  end

  def test_reads_quoted_keys
    @formatter.read StringIO.new('"key" = "value"'), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['key'].translations['en']
  end

  def test_reads_unquoted_keys
    @formatter.read StringIO.new('key = "value"'), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['key'].translations['en']
  end

  def test_ignores_leading_whitespace_before_quoted_keys
    @formatter.read StringIO.new("\t  \"key\" = \"value\""), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['key'].translations['en']
  end

  def test_ignores_leading_whitespace_before_unquoted_keys
    @formatter.read StringIO.new("\t  key = \"value\""), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['key'].translations['en']
  end

  def test_allows_quotes_in_quoted_keys
    @formatter.read StringIO.new('"ke\"y" = "value"'), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['ke"y'].translations['en']
  end

  def test_does_not_allow_quotes_in_quoted_keys
    @formatter.read StringIO.new('ke"y = "value"'), 'en'
    assert_nil @empty_twine_file.definitions_by_key['key']
  end

  def test_allows_equal_signs_in_quoted_keys
    @formatter.read StringIO.new('"k=ey" = "value"'), 'en'
    assert_equal 'value', @empty_twine_file.definitions_by_key['k=ey'].translations['en']
  end

  def test_does_not_allow_equal_signs_in_unquoted_keys
    @formatter.read StringIO.new('k=ey = "value"'), 'en'
    assert_nil @empty_twine_file.definitions_by_key['key']
  end

  def test_format_file
    formatter = Twine::Formatters::Apple.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_apple.strings'), formatter.format_file('en')
  end

  def test_format_key_with_space
    assert_equal 'key ', @formatter.format_key('key ')
  end

  def test_format_value_with_leading_space
    assert_equal ' value', @formatter.format_value(' value')
  end

  def test_format_value_with_trailing_space
    assert_equal 'value ', @formatter.format_value('value ')
  end
end

class TestJQueryFormatter < FormatterTest

  def setup
    super Twine::Formatters::JQuery
  end

  def test_read_format
    @formatter.read content_io('formatter_jquery.json'), 'en'

    assert_translations_read_correctly
  end

  def test_format_file
    formatter = Twine::Formatters::JQuery.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_jquery.json'), formatter.format_file('en')
  end

  def test_empty_sections_are_removed
    @twine_file = build_twine_file 'en' do
      add_section 'Section 1' do
      end

      add_section 'Section 2' do
        add_definition key: 'value'
      end
    end
    formatter = Twine::Formatters::JQuery.new
    formatter.twine_file = @twine_file
    refute_includes formatter.format_file('en'), ','
  end

  def test_format_value_with_newline
    assert_equal "value\nwith\nline\nbreaks", @formatter.format_value("value\nwith\nline\nbreaks")
  end

  def test_deducts_language_from_filename
    language = KNOWN_LANGUAGES.sample
    assert_equal language, @formatter.determine_language_given_path("#{language}.json")
  end

  def test_deducts_language_from_extended_filename
    language = KNOWN_LANGUAGES.sample
    assert_equal language, @formatter.determine_language_given_path("something-#{language}.json")
  end

  def test_deducts_language_from_path
    language = %w(en-GB de fr).sample
    assert_equal language, @formatter.determine_language_given_path("/output/#{language}/#{@formatter.default_file_name}")
  end
end

class TestGettextFormatter < FormatterTest
  def setup
    super Twine::Formatters::Gettext
  end

  def test_read_format
    @formatter.read content_io('formatter_gettext.po'), 'en'

    assert_file_contents_read_correctly
  end

  def test_read_with_multiple_line_value
    @formatter.read content_io('gettext_multiline.po'), 'en'

    assert_equal 'multiline\nstring', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_format_file
    formatter = Twine::Formatters::Gettext.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_gettext.po'), formatter.format_file('en')
  end

  def test_deducts_language_and_region
    language = "en-GB"
    assert_equal language, @formatter.determine_language_given_path("#{language}.po")
  end

  def test_deducts_language_from_path
    language = %w(en-GB de fr).sample
    assert_equal language, @formatter.determine_language_given_path("/output/#{language}/#{@formatter.default_file_name}")
  end
end

class TestTizenFormatter < FormatterTest

  def setup
    super Twine::Formatters::Tizen
  end

  def test_read_format
    skip 'the current implementation of Tizen formatter does not support reading'
    @formatter.read content_io('formatter_tizen.xml'), 'en'

    assert_file_contents_read_correctly
  end

  def test_format_file
    formatter = Twine::Formatters::Tizen.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_tizen.xml'), formatter.format_file('en')
  end
end

class TestDjangoFormatter < FormatterTest
  def setup
    super Twine::Formatters::Django
  end

  def test_read_format
    @formatter.read content_io('formatter_django.po'), 'en'

    assert_file_contents_read_correctly
  end

  def test_format_file
    formatter = Twine::Formatters::Django.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_django.po'), formatter.format_file('en')
  end

  def test_deducts_language_and_region
    language = "en-GB"
    assert_equal language, @formatter.determine_language_given_path("#{language}.po")
  end

  def test_deducts_language_from_path
    language = %w(en-GB de fr).sample
    assert_equal language, @formatter.determine_language_given_path("/output/#{language}/#{@formatter.default_file_name}")
  end
end

class TestFlashFormatter < FormatterTest
  def setup
    super Twine::Formatters::Flash
  end

  def test_read_format
    @formatter.read content_io('formatter_flash.properties'), 'en'

    assert_file_contents_read_correctly
  end

  def test_set_translation_converts_placeholders
    @formatter.set_translation_for_key 'key1', 'en', "value {#{rand(10)}}"
    assert_equal 'value %@', @empty_twine_file.definitions_by_key['key1'].translations['en']
  end

  def test_format_file
    formatter = Twine::Formatters::Flash.new
    formatter.twine_file = @twine_file
    assert_equal content('formatter_flash.properties'), formatter.format_file('en')
  end

  def test_format_value_converts_placeholders
    assert_equal "value {0}", @formatter.format_value('value %d')
  end

  def test_deducts_language_from_resource_folder
    language = %w(en de fr).sample
    assert_equal language, @formatter.determine_language_given_path("locale/#{language}/#{@formatter.default_file_name}")
  end

  def test_deducts_language_and_region_from_resource_folder
    assert_equal 'de-AT', @formatter.determine_language_given_path("locale/de-AT/#{@formatter.default_file_name}")
  end
end
