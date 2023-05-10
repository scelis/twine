module Twine
  module Formatters
    class JQuery < Abstract
      def format_name
        'jquery'
      end

      def extension
        '.json'
      end

      def default_file_name
        'localize.json'
      end

      def default_plurals_file_name
        ''
      end

      def determine_language_given_path(path)
        match = /^.+-([^-]{2})\.json$/.match File.basename(path)
        return match[1] if match

        return super
      end

      def format_file(lang)
        result = super
        unless result
          return FormatterResult.new("{\n\n}\n", nil)
        end

        output = "{\n"
        output += result.singleOutput
        if (result.singleOutput != "" && result.pluralsOutput != "")
          output += ",\n"
        end
        output += result.pluralsOutput
        output += "\n}\n"
        FormatterResult.new(output, nil)
      end

      def format_sections(twine_file, lang, handlePlurals)
        sections = twine_file.sections.map { |section| format_section(section, lang, handlePlurals) }
        sections.delete_if(&:empty?)
        sections.join(",\n\n")
      end

      def format_section_header(section)
      end

      def format_section(section, lang, handlePlurals)
        definitions = prepareDefinitions(section, lang, handlePlurals)
        return "" if definitions.empty?

        definitions.map! { |definition| format_definition(definition, lang, definition.translations.find { |t| t.pluralValues.empty? } == nil) }
        definitions.compact! # remove nil definitions
        definitions.join(",\n")
      end

      def key_value_pattern
        "\"%{key}\":\"%{value}\""
      end

      def format_pluralized_value(key, pluralValues, lang)
        result = ''
        result += pluralValues.map { |plural_key, plural_value|
          "\"#{key}_#{plural_key}\":\"#{escape_quotes(plural_value)}\""
        }.join(",\n")
        result
      end

      def format_key(key)
        escape_quotes(key)
      end

      def format_value(value)
        escape_quotes(value)
      end
    end
  end
end

Twine::Formatters.formatters << Twine::Formatters::JQuery.new
