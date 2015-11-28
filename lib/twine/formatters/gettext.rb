# encoding: utf-8

module Twine
  module Formatters
    class Gettext < Abstract
      FORMAT_NAME = 'gettext'
      EXTENSION = '.po'
      DEFAULT_FILE_NAME = 'strings.po'

      def self.can_handle_directory?(path)
        Dir.entries(path).any? { |item| /^.+\.po$/.match(item) }
      end

      def default_file_name
        return DEFAULT_FILE_NAME
      end

      def determine_language_given_path(path)
        path_arr = path.split(File::SEPARATOR)
        path_arr.each do |segment|
          match = /(..)\.po$/.match(segment)
          if match
            return match[1]
          end
        end

        return
      end

      def read_file(path, lang)
        comment_regex = /#.? *"(.*)"$/
        key_regex = /msgctxt *"(.*)"$/
        value_regex = /msgstr *"(.*)"$/m
        File.open(path, 'r:UTF-8') do |f|
          while item = f.gets("\n\n")
            key = nil
            value = nil
            comment = nil

            comment_match = comment_regex.match(item)
            if comment_match
              comment = comment_match[1]
            end
            key_match = key_regex.match(item)
            if key_match
              key = key_match[1].gsub('\\"', '"')
            end
            value_match = value_regex.match(item)
            if value_match
              value = value_match[1].gsub(/"\n"/, '').gsub('\\"', '"')
            end
            if key and key.length > 0 and value and value.length > 0
              set_translation_for_key(key, lang, value)
              if comment and comment.length > 0 and !comment.start_with?("SECTION:")
                set_comment_for_key(key, comment)
              end
              comment = nil
            end
          end
        end
      end

      def format_file(strings, lang)
        @default_lang = strings.language_codes[0]
        super
      end

      def format_header(lang)
        "msgid \"\"\nmsgstr \"\"\n\"Language: #{lang}\\n\"\n\"X-Generator: Twine #{Twine::VERSION}\\n\"\n"
      end

      def format_section_header(section)
        "# SECTION: #{section.name}"
      end

      def format_row(row, lang)
        return nil unless row.translated_string_for_lang(@default_lang)

        value = row.translated_string_for_lang(lang)

        return nil unless value

        result = ""
        if row.comment
          comment = format_comment(row.comment)
          result += comment + "\n" if comment
        end

        result += "msgctxt \"#{format_key(row.key.dup)}\"\n"
        result += "msgid \"#{format_value(row.translations[@default_lang])}\"\n"
        result += "msgstr \"#{format_value(value)}\"\n"
      end

      def format_comment(comment)
        "#. \"#{escape_quotes(comment)}\""
      end
    end
  end
end
