require 'fileutils'

module Twine
  module Formatters
    class Abstract
      attr_accessor :strings
      attr_accessor :options

      def initialize
        @strings = StringsFile.new
        @options = {}
      end

      def format_name
        raise NotImplementedError.new("You must implement format_name in your formatter class.")
      end

      def extension
        raise NotImplementedError.new("You must implement extension in your formatter class.")
      end

      def can_handle_directory?(path)
        raise NotImplementedError.new("You must implement can_handle_directory? in your formatter class.")
      end

      def default_file_name
        raise NotImplementedError.new("You must implement default_file_name in your formatter class.")
      end

      def set_translation_for_key(key, lang, value)
        value = value.gsub("\n", "\\n")

        if @strings.strings_map.include?(key)
          row = @strings.strings_map[key]
          reference = @strings.strings_map[row.reference_key] if row.reference_key

          if !reference or value != reference.translations[lang]
            row.translations[lang] = value
          end
        elsif @options[:consume_all]
          Twine::stderr.puts "Adding new string '#{key}' to strings data file."
          current_section = @strings.sections.find { |s| s.name == 'Uncategorized' }
          unless current_section
            current_section = StringsSection.new('Uncategorized')
            @strings.sections.insert(0, current_section)
          end
          current_row = StringsRow.new(key)
          current_section.rows << current_row
          
          if @options[:tags] && @options[:tags].length > 0
            current_row.tags = @options[:tags]            
          end
          
          @strings.strings_map[key] = current_row
          @strings.strings_map[key].translations[lang] = value
        else
          Twine::stderr.puts "Warning: '#{key}' not found in strings data file."
        end
        if !@strings.language_codes.include?(lang)
          @strings.add_language_code(lang)
        end
      end

      def set_comment_for_key(key, comment)
        return unless @options[:consume_comments]
        
        if @strings.strings_map.include?(key)
          row = @strings.strings_map[key]
          
          reference = @strings.strings_map[row.reference_key] if row.reference_key

          if !reference or comment != reference.raw_comment
            row.comment = comment
          end
        end
      end

      def determine_language_given_path(path)
        raise NotImplementedError.new("You must implement determine_language_given_path in your formatter class.")
      end

      def output_path_for_language(lang)
        lang
      end

      def read_file(path, lang)
        raise NotImplementedError.new("You must implement read_file in your formatter class.")
      end

      def format_file(strings, lang)
        header = format_header(lang)
        result = ""
        result += header + "\n" if header
        result += format_sections(strings, lang)
      end

      def format_header(lang)
      end

      def format_sections(strings, lang)
        sections = strings.sections.map { |section| format_section(section, lang) }
        sections.compact.join("\n")
      end

      def format_section_header(section)
      end

      def should_include_row(row, lang)
        row.translated_string_for_lang(lang)
      end

      def format_section(section, lang)
        rows = section.rows.select { |row| should_include_row(row, lang) }
        return if rows.empty?

        result = ""

        if section.name && section.name.length > 0
          section_header = format_section_header(section)
          result += "\n#{section_header}" if section_header
        end

        rows.map! { |row| format_row(row, lang) }
        rows.compact! # remove nil entries
        rows.map! { |row| "\n#{row}" }  # prepend newline
        result += rows.join
      end

      def format_row(row, lang)
        [format_comment(row, lang), format_key_value(row, lang)].compact.join
      end

      def format_comment(row, lang)
      end

      def format_key_value(row, lang)
        value = row.translated_string_for_lang(lang)
        key_value_pattern % { key: format_key(row.key.dup), value: format_value(value.dup) }
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

      def write_file(path, lang)
        output_processor = Processors::OutputProcessor.new(@strings, @options)
        processed_strings = output_processor.process(lang)

        encoding = @options[:output_encoding] || 'UTF-8'
        File.open(path, "w:#{encoding}") do |f|
          f.puts format_file(processed_strings, lang)
        end
      end

      def write_all_files(path)
        file_name = @options[:file_name] || default_file_name
        if @options[:create_folders]
          @strings.language_codes.each do |lang|
            output_path = File.join(path, output_path_for_language(lang))

            FileUtils.mkdir_p(output_path)

            file_path = File.join(output_path, file_name)
            write_file(file_path, lang)
          end
        else
          language_written = false
          Dir.foreach(path) do |item|
            next if item == "." or item == ".."

            item = File.join(path, item)
            next unless File.directory?(item)

            lang = determine_language_given_path(item)
            next unless lang

            file_path = File.join(item, file_name)
            write_file(file_path, lang)
            language_written = true
          end

          if !language_written
            raise Twine::Error.new("Failed to generate any files: No languages found at #{path}")
          end
        end
      end

    end
  end
end
