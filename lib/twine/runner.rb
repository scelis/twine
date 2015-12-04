require 'tmpdir'
require 'fileutils'

Twine::Plugin.new # Initialize plugins first in Runner.

module Twine
  class Runner
    def self.run(args)
      options = CLI.parse(args)
      
      strings = StringsFile.new
      strings.read options[:strings_file]
      runner = new(options, strings)

      case options[:command]
      when 'generate-string-file'
        runner.generate_string_file
      when 'generate-all-string-files'
        runner.generate_all_string_files
      when 'consume-string-file'
        runner.consume_string_file
      when 'consume-all-string-files'
        runner.consume_all_string_files
      when 'generate-loc-drop'
        runner.generate_loc_drop
      when 'consume-loc-drop'
        runner.consume_loc_drop
      when 'validate-strings-file'
        runner.validate_strings_file
      end
    end

    def initialize(options = {}, strings = StringsFile.new)
      @options = options
      @strings = strings
    end

    def write_strings_data(path)
      if @options[:developer_language]
        @strings.set_developer_language_code(@options[:developer_language])
      end
      @strings.write(path)
    end

    def generate_string_file
      lang = nil
      lang = @options[:languages][0] if @options[:languages]

      read_write_string_file(@options[:output_path], false, lang)
    end

    def generate_all_string_files
      if !File.directory?(@options[:output_path])
        if @options[:create_folders]
          FileUtils.mkdir_p(@options[:output_path])
        else
          raise Twine::Error.new("Directory does not exist: #{@options[:output_path]}")
        end
      end

      format = @options[:format] || determine_format_given_directory(@options[:output_path])
      unless format
        raise Twine::Error.new "Could not determine format given the contents of #{@options[:output_path]}"
      end

      formatter = formatter_for_format(format)

      formatter.write_all_files(@options[:output_path])
    end

    def consume_string_file
      lang = nil
      if @options[:languages]
        lang = @options[:languages][0]
      end

      read_write_string_file(@options[:input_path], true, lang)
      output_path = @options[:output_path] || @options[:strings_file]
      write_strings_data(output_path)
    end

    def consume_all_string_files
      if !File.directory?(@options[:input_path])
        raise Twine::Error.new("Directory does not exist: #{@options[:output_path]}")
      end

      Dir.glob(File.join(@options[:input_path], "**/*")) do |item|
        if File.file?(item)
          begin
            read_write_string_file(item, true, nil)
          rescue Twine::Error => e
            Twine::stderr.puts "#{e.message}"
          end
        end
      end

      output_path = @options[:output_path] || @options[:strings_file]
      write_strings_data(output_path)
    end

    def read_write_string_file(path, is_read, lang)
      if is_read && !File.file?(path)
        raise Twine::Error.new("File does not exist: #{path}")
      end

      format = @options[:format] || determine_format_given_path(path)
      unless format
        raise Twine::Error.new "Unable to determine format of #{path}"
      end

      formatter = formatter_for_format(format)

      lang = lang || determine_language_given_path(path) || formatter.determine_language_given_path(path)
      unless lang
        raise Twine::Error.new "Unable to determine language for #{path}"
      end

      if !@strings.language_codes.include? lang
        @strings.language_codes << lang
      end

      if is_read
        formatter.read_file(path, lang)
      else
        formatter.write_file(path, lang)
      end
    end

    def generate_loc_drop
      require_rubyzip

      if File.file?(@options[:output_path])
        File.delete(@options[:output_path])
      end

      Dir.mktmpdir do |dir|
        Zip::File.open(@options[:output_path], Zip::File::CREATE) do |zipfile|
          zipfile.mkdir('Locales')

          formatter = formatter_for_format(@options[:format])
          @strings.language_codes.each do |lang|
            if @options[:languages] == nil || @options[:languages].length == 0 || @options[:languages].include?(lang)
              file_name = lang + formatter.class::EXTENSION
              real_path = File.join(dir, file_name)
              zip_path = File.join('Locales', file_name)
              formatter.write_file(real_path, lang)
              zipfile.add(zip_path, real_path)
            end
          end
        end
      end
    end

    def consume_loc_drop
      require_rubyzip

      if !File.file?(@options[:input_path])
        raise Twine::Error.new("File does not exist: #{@options[:input_path]}")
      end

      Dir.mktmpdir do |dir|
        Zip::File.open(@options[:input_path]) do |zipfile|
          zipfile.each do |entry|
            if !entry.name.end_with?'/' and !File.basename(entry.name).start_with?'.'
              real_path = File.join(dir, entry.name)
              FileUtils.mkdir_p(File.dirname(real_path))
              zipfile.extract(entry.name, real_path)
              begin
                read_write_string_file(real_path, true, nil)
              rescue Twine::Error => e
                Twine::stderr.puts "#{e.message}"
              end
            end
          end
        end
      end

      output_path = @options[:output_path] || @options[:strings_file]
      write_strings_data(output_path)
    end

    def validate_strings_file
      total_strings = 0
      all_keys = Set.new
      duplicate_keys = Set.new
      keys_without_tags = Set.new
      errors = []

      @strings.sections.each do |section|
        section.rows.each do |row|
          total_strings += 1

          if all_keys.include? row.key
            duplicate_keys.add(row.key)
          else
            all_keys.add(row.key)
          end

          if row.tags == nil || row.tags.length == 0
            keys_without_tags.add(row.key)
          end
        end
      end

      if duplicate_keys.length > 0
        error_body = duplicate_keys.to_a.join("\n  ")
        errors << "Found duplicate string key(s):\n  #{error_body}"
      end

      if keys_without_tags.length == total_strings
        errors << "None of your strings have tags."
      elsif keys_without_tags.length > 0
        error_body = keys_without_tags.to_a.join("\n  ")
        errors << "Found strings(s) without tags:\n  #{error_body}"
      end

      if errors.length > 0
        raise Twine::Error.new errors.join("\n\n")
      end

      Twine::stdout.puts "#{@options[:strings_file]} is valid."
    end

    def determine_language_given_path(path)
      code = File.basename(path, File.extname(path))
      return code if @strings.language_codes.include? code
    end

    def determine_format_given_path(path)
      formatter = Formatters.formatters.find { |f| f::EXTENSION == File.extname(path) }
      return formatter::FORMAT_NAME if formatter
    end

    def determine_format_given_directory(directory)
      formatter = Formatters.formatters.find { |f| f.can_handle_directory?(directory) }
      return formatter::FORMAT_NAME if formatter
    end

    def formatter_for_format(format)
      formatter = Formatters.formatters.find { |f| f::FORMAT_NAME == format }
      return formatter.new(@strings, @options) if formatter
    end

    private

    def require_rubyzip
      begin
        require 'zip'
      rescue LoadError
        raise Twine::Error.new "You must run 'gem install rubyzip' in order to create or consume localization drops."
      end
    end
  end
end
