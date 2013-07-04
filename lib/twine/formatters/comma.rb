require 'csv'

module Twine
  module Formatters
    class Comma < Abstract
      FORMAT_NAME = 'csv'
      EXTENSION = '.csv'
      DEFAULT_FILE_NAME = 'strings.properties'
      INSTRUCTIONS = 'Instructions: write translations in the column named'

      def self.can_handle_directory?(path)
        Dir.entries(path).any? { |item| /^.+\.csv$/.match(item) }
      end

      def default_file_name
        return DEFAULT_FILE_NAME
      end

      def determine_language_given_path(path)
        path_arr = path.split(File::SEPARATOR)
        path_arr.each do |segment|
          match = /(..)\.csv$/.match(segment)
          if match
            return match[1]
          end
        end

        return
      end

      def read_file(path, lang)
        CSV.foreach(path).each do |row|
          next if row.length != 4
          next if row[0] == 'key' && row[3] == 'comment'
          key = row[0]
          value = row[2]
          comment = row[3]

          if key and key.length > 0 and value and value.length > 0
            set_translation_for_key(key, lang, value)
            if comment and comment.length > 0
              set_comment_for_key(key, comment)
            end
          end
        end
      end

      def write_file(path, lang)
        default_lang = @strings.language_codes[0]
        CSV.open(path, 'w') do |csv|
          csv << ["key", "#{default_lang}", "#{lang}", "comment"]
          @strings.sections.each do |section|
            printed_section = false
            section.rows.each do |row|
              if row.matches_tags?(@options[:tags], @options[:untagged])
                basetrans = row.translated_string_for_lang(default_lang)

                if basetrans
                  key = row.key
                  key = key.gsub('"', '\\\\"')

                  comment = row.comment
                  if comment
                    comment = comment.gsub('"', '\\\\"')
                  end

                  value = row.translated_string_for_lang(lang)
                  if value
                    value = value.gsub('"', '\\\\"')
                  end

                  csv << ["#{key}", "#{basetrans}", "#{value}", "#{comment}"]
                end
              end
            end
          end
        end
      end
    end
  end
end
