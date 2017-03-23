require 'csv'

module Twine
  module Formatters
    class CSV < Abstract
      def format_name
        'CSV'
      end

      def extension
        '.csv'
      end

      def default_file_name
        'strings.csv'
      end

      def determine_language_given_path(path)
        path_arr = path.split(File::SEPARATOR)
        path_arr.each do |segment|
          match = /-(.+)\.csv$/.match(segment)
          return match[1] if match
        end

        return
      end

      def read(io, lang)
        while line = io.gets
          fields = ::CSV.parse_line(line)

          key = fields[0]
          value = fields[1]
          comment = fields[2]

          # checks for nil, empty and whitespace
          if key =~ /\S/ and value =~ /\S/
            set_translation_for_key(key, lang, value)
            set_comment_for_key(key, comment) if comment =~ /\S/
          end
        end
      end

      def format_header(lang)
        'Key,Value,Comment'
      end

      def format_section(section, lang)
        # removes newline above section
        super.strip
      end

      def format_definition(definition, lang)
        key = definition.key
        value = definition.translation_for_lang(lang)
        comment = definition.comment

        ::CSV.generate_line([key, value, comment], row_sep: '', force_quotes: true)
      end
    end
  end
end

Twine::Formatters.formatters << Twine::Formatters::CSV.new
