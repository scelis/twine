require 'fileutils'

module Twine
  module Formatters
    class FormatterResult
      attr_accessor :singleOutput
      attr_accessor :pluralsOutput
      
      def initialize(single, plurals)
        @singleOutput = single
        @pluralsOutput = plurals
      end
    end

    class Abstract
      LANGUAGE_CODE_WITH_OPTIONAL_REGION_CODE = "[a-z]{2}(?:-[A-Za-z]{2})?"

      attr_accessor :twine_file
      attr_accessor :options

      def initialize
        @twine_file = TwineFile.new
        @options = {}
      end

      def format_name
        raise NotImplementedError.new("You must implement format_name in your formatter class.")
      end

      def extension
        raise NotImplementedError.new("You must implement extension in your formatter class.")
      end

      def can_handle_directory?(path)
        Dir.entries(path).any? { |item| /^.+#{Regexp.escape(extension)}$/.match(item) }
      end

      def default_file_name
        raise NotImplementedError.new("You must implement default_file_name in your formatter class.")
      end

      def default_plurals_file_name
        raise NotImplementedError.new("You must implement default_file_name in your formatter class.")
      end

      def determine_language_given_path(path)
        only_language_and_region = /^#{LANGUAGE_CODE_WITH_OPTIONAL_REGION_CODE}$/i
        basename = File.basename(path, File.extname(path))
        return basename if basename =~ only_language_and_region
        return basename if @twine_file.language_codes.include? basename
        
        path.split(File::SEPARATOR).reverse.find { |segment| segment =~ only_language_and_region }
      end

      def output_path_for_language(lang)
        lang
      end

      def format_file(lang)
        return nil if @twine_file.definitions_by_key.empty?

        header = format_header(lang)

        result = ""
        result += header + "\n" if header
        result += format_sections(@twine_file, lang, false)

        pluralsHeader = format_plurals_header(lang)
        pluralsResult = ""
        pluralsResult += pluralsHeader + "\n" if pluralsHeader
        pluralsResult += format_sections(@twine_file, lang, true)

        FormatterResult.new(result, pluralsResult)
      end

      def format_header(lang)
      end

      def format_plurals_header(lang)
        format_header(lang)
      end

      def format_sections(twine_file, lang, handlePlurals)
        sections = twine_file.sections.map { |section| format_section(section, lang, handlePlurals) }
        sections.compact.join("\n")
      end

      def format_section_header(section, handlPlurals)
      end

      def should_include_definition(definition, lang)
        return !definition.translation_for_lang(lang).nil?
      end

      def prepareDefinitions(section, lang, handlePlurals)
        definitionsToHandle = section.definitions.map { |definition|
          translations = if handlePlurals
            definition.translations.filter { |translation| translation.singleValue == nil }
          else
            definition.translations.filter { |translation| translation.singleValue != nil }
          end

          newDefinition = definition.dup
          newDefinition.translations = translations
          newDefinition
        }
        definitionsToHandle.select { |definition| should_include_definition(definition, lang) }
      end

      def format_section(section, lang, handlePlurals)
        result = ""

        if section.name && section.name.length > 0
          section_header = format_section_header(section, handlePlurals)
          result += "\n#{section_header}" if section_header
        end

        definitions = prepareDefinitions(section, lang, handlePlurals)
        return result if definitions.empty?

        definitions.map! { |definition| format_definition(definition, lang, handlePlurals) }
        definitions.compact! # remove nil definitions
        definitions.map! { |definition| "\n#{definition}" }  # prepend newline
        result += definitions.join
      end

      def format_definition(definition, lang, isPlural)
        [format_comment(definition, lang), format_key_value(definition, lang, isPlural)].compact.join
      end

      def format_comment(definition, lang)
      end

      def format_key_value(definition, lang, isPlural)
        value = definition.translation_for_lang(lang)
        if isPlural
          format_pluralized_value(definition.key.dup, value.pluralValues.dup, lang)
        else
          key_value_pattern % { key: format_key(definition.key.dup), value: format_value(value.singleValue.dup) }
        end
      end

      def format_pluralized_value(key, pluralValues, lang)
        raise NotImplementedError.new("You must implement format_pluralized_value in your formatter class.")
      end

      def key_value_pattern
        raise NotImplementedError.new("You must implement key_value_pattern in your formatter class.")
      end

      def format_key(key)
        key
      end

      def format_value(value)
        value
      end

      def escape_quotes(text)
        text.gsub('"', '\\\\"')
      end
    end
  end
end
