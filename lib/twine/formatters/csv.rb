module Twine
  module Formatters
    class Csv < Abstract
      FORMAT_NAME = 'csv'
      EXTENSION = '.csv'
      DEFAULT_FILE_NAME = 'strings.csv'

      def self.can_handle_directory?(path)
        return false
      end

      def can_handle_mutiple_languages?()
        return true
      end

      def default_file_name
        return DEFAULT_FILE_NAME
      end

      def determine_language_given_path(path)
        return
      end

      def read_file(path, lang)
        encoding = Twine::Encoding.encoding_for_path(path)
        sep = nil
        if !encoding.respond_to?(:encode)
          # This code is not necessary in 1.9.3 and does not work as it did in 1.8.7.
          if encoding.end_with? 'LE'
            sep = "\x0a\x00"
          elsif encoding.end_with? 'BE'
            sep = "\x00\x0a"
          else
            sep = "\n"
          end
        end

        if encoding.index('UTF-16')
          mode = "rb:#{encoding}"
        else
          mode = "r:#{encoding}"
        end

        firstLine = true

        File.open(path, mode) do |f|
          last_comment = nil
          while line = (sep) ? f.gets(sep) : f.gets
            if encoding.index('UTF-16')
              if line.respond_to? :encode!
                line.encode!('UTF-8')
              else
                require 'iconv'
                line = Iconv.iconv('UTF-8', encoding, line).join
              end
            end

            if firstLine
              firstLine = false
              fields = line.parse_csv
            else

              langs = fields.dup

              keyIdx = fields.index('Key')
              commentIdx = fields.index('Comment')
              line = line.parse_csv

              key = line[keyIdx]
              langs.delete_at(keyIdx)

              comment = line[commentIdx]
              langs.delete_at(commentIdx)

              langs.each do |theLang|

                langIdx = fields.index(theLang)

                if lang.include? theLang
                  set_translation_for_key(key, theLang, line[langIdx])

                  if @options[:consume_comments]
                    set_comment_for_key(key, line[commentIdx])
                  end
                end

              end
            end
          end
        end
      end

      def write_file(path, lang)
        default_lang = @strings.language_codes[0]
        encoding = @options[:output_encoding] || 'UTF-8'
        File.open(path, "w:#{encoding}") do |f|
          f.write "Key,Comment"
          lang.each do |thelang|
            f.write ",#{thelang}"
          end
          f.write "\n"

          @strings.sections.each do |section|
            section.rows.each do |row|

              if row.matches_tags?(@options[:tags], @options[:untagged])

                translated = true
                values = ""

                lang.each do |thelang|
                  value = row.translated_string_for_lang(thelang, default_lang)
                  value = value.gsub('"', '\\\\"')
                  values << ",\"#{value}\""

                  if !row.translated_string_for_lang(thelang, nil)
                    translated = false
                  end
                end

                if !@options[:untranslated_only] || !translated

                  f.write "\"#{row.key}\""
                  comment = row.comment

                  if comment
                    comment = comment.gsub('"', '\\\\"')
                  end
                  f.write ",\"#{comment}\""

                  lang.each do |thelang|
                    value = row.translated_string_for_lang(thelang, default_lang)
                    value = value.gsub('"', '\\\\"')
                    f.write ",\"#{values}\""
                  end

                  f.write "\n"
                end
              end
            end
          end
        end
    end
  end
end
end
