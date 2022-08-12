module Twine
  module Formatters
    class Flutter < Abstract
      def format_name
        'flutter'
      end

      def extension
        '.arb'
      end

      def default_file_name
        'app.arb'
      end

      def determine_language_given_path(path)
        match = /^.+_([^-]{2})\.arb$/.match File.basename(path)
        return match[1] if match

        return super
      end

      def read(io, lang)
        begin
          require "json"
        rescue LoadError
          raise Twine::Error.new "You must run `gem install json` in order to read or write flutter files."
        end

        json = JSON.load(io)
        json.each do |key, value|
          if key == "@@locale"
            # Ignore because it represents the file lang
          elsif key[0,1] == "@"
            description_value = "{\n        \"description\":\"#{value}\"\n    }"
            set_comment_for_key(key.slice!(0), lang, value)
          else
            set_translation_for_key(key, lang, value)
        end
      end

      def format_file(lang)
        result = super
        return result unless result
        "{\n    \"@@locale\": \"%{lang}\",\n#{super}\n}\n"
      end

      def format_sections(twine_file, lang)
        sections = twine_file.sections.map { |section| format_section(section, lang) }
        sections.delete_if(&:empty?)
        sections.join(",\n\n")
      end

      def format_section_header(section)
      end

      def format_section(section, lang)
        definitions = section.definitions.dup

        definitions.map! { |definition| format_definition(definition, lang) }
        definitions.compact! # remove nil definitions
        definitions.join(",\n")
      end

      def key_value_pattern
        "    \"%{key}\": \"%{value}\""
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

Twine::Formatters.formatters << Twine::Formatters::Flutter.new
