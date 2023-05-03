require 'tmpdir'
require 'fileutils'

Twine::Plugin.new # Initialize plugins first in Runner.

module Twine
  class Runner
    class NullOutput
      def puts(message)
      end
      def string
        ""
      end
    end

    def self.run(args)
      options = CLI.parse(args)

      return unless options
      
      twine_file = TwineFile.new
      twine_file.read options[:twine_file]
      runner = new(options, twine_file)

      case options[:command]
      when 'generate-all-localization-files'
        runner.generate_all_localization_files
      when 'validate-twine-file'
        runner.validate_twine_file
      end
    end

    def initialize(options = {}, twine_file = TwineFile.new)
      @options = options
      @twine_file = twine_file
      if @options[:quite]
        Twine::stdout = NullOutput.new
      end
    end

    def generate_all_localization_files
      validate_twine_file if @options[:validate]

      if !File.directory?(@options[:output_path])
        if @options[:create_folders]
          FileUtils.mkdir_p(@options[:output_path])
        else
          raise Twine::Error.new("Directory does not exist: #{@options[:output_path]}")
        end
      end

      if @options[:format]
        formatter = formatter_for_format(@options[:format])
      else
        formatter = find_formatter { |f| f.can_handle_directory?(@options[:output_path]) }
      end
      
      unless formatter
        raise Twine::Error.new "Could not determine format given the contents of #{@options[:output_path]}. Try using `--format`."
      end

      file_name = @options[:file_name] || formatter.default_file_name
      plurals_file_name = formatter.default_plurals_file_name
      if @options[:create_folders]
        @twine_file.language_codes.each do |lang|
          output_path = File.join(@options[:output_path], formatter.output_path_for_language(lang))

          FileUtils.mkdir_p(output_path)

          file_path = File.join(output_path, file_name)

          output = formatter.format_file(lang)
          unless output
            Twine::stdout.puts "Skipping file at path #{file_path} since it would not contain any translations."
            next
          end

          if output.singleOutput
            IO.write(file_path, output.singleOutput, encoding: output_encoding)
          end

          if output.pluralsOutput
            IO.write(File.join(output_path, plurals_file_name), output.pluralsOutput, encoding: output_encoding)
          end
        end
      else
        language_found = false
        Dir.foreach(@options[:output_path]) do |item|
          next if item == "." or item == ".."

          output_path = File.join(@options[:output_path], item)
          next unless File.directory?(output_path)

          lang = formatter.determine_language_given_path(output_path)
          next unless lang

          language_found = true

          file_path = File.join(output_path, file_name)
          output = formatter.format_file(lang)
          unless output
            Twine::stdout.puts "Skipping file at path #{file_path} since it would not contain any translations."
            next
          end

          if output.singleOutput
            IO.write(file_path, output, encoding: output_encoding)
          end

          if output.pluralsOutput
            IO.write(File.join(output_path, plurals_file_name), output.pluralsOutput, encoding: output_encoding)
          end
        end

        unless language_found
          raise Twine::Error.new("Failed to generate any files: No languages found at #{@options[:output_path]}")
        end
      end
    end

    def validate_twine_file
      total_definitions = 0
      all_keys = Set.new
      duplicate_keys = Set.new
      keys_without_tags = Set.new
      invalid_keys = Set.new
      keys_with_python_only_placeholders = Set.new
      valid_key_regex = /^[A-Za-z0-9_]+$/

      @twine_file.sections.each do |section|
        section.definitions.each do |definition|
          total_definitions += 1

          duplicate_keys.add(definition.key) if all_keys.include? definition.key
          all_keys.add(definition.key)

          keys_without_tags.add(definition.key) if definition.tags == nil or definition.tags.length == 0

          invalid_keys << definition.key unless definition.key =~ valid_key_regex

          keys_with_python_only_placeholders << definition.key if definition.translations.values.any? { |v| Placeholders.contains_python_specific_placeholder(v) }
        end
      end

      errors = []
      join_keys = lambda { |set| set.map { |k| "  " + k }.join("\n") }

      unless duplicate_keys.empty?
        errors << "Found duplicate key(s):\n#{join_keys.call(duplicate_keys)}"
      end

      if @options[:pedantic]
        if keys_without_tags.length == total_definitions
          errors << "None of your definitions have tags."
        elsif keys_without_tags.length > 0
          errors << "Found definitions without tags:\n#{join_keys.call(keys_without_tags)}"
        end
      end

      unless invalid_keys.empty?
        errors << "Found key(s) with invalid characters:\n#{join_keys.call(invalid_keys)}"
      end

      unless keys_with_python_only_placeholders.empty?
        errors << "Found key(s) with placeholders that are only supported by Python:\n#{join_keys.call(keys_with_python_only_placeholders)}"
      end

      raise Twine::Error.new errors.join("\n\n") unless errors.empty?

      Twine::stdout.puts "#{@options[:twine_file]} is valid."
    end

    private

    def output_encoding
      @options[:encoding] || 'UTF-8'
    end

    def require_rubyzip
      begin
        require 'zip'
      rescue LoadError
        raise Twine::Error.new "You must run 'gem install rubyzip' in order to create or consume localization archives."
      end
    end

    def formatter_for_format(format)
      find_formatter { |f| f.format_name == format }
    end

    def find_formatter(&block)
      formatters = Formatters.formatters.select(&block)
      if formatters.empty?
        return nil
      elsif formatters.size > 1
        raise Twine::Error.new("Unable to determine format. Candidates are: #{formatters.map(&:format_name).join(', ')}. Please specify the format you want using `--format`")
      end
      formatter = formatters.first
      formatter.twine_file = @twine_file
      formatter.options = @options
      formatter
    end

    def prepare_read_write(path, lang)
      if @options[:format]
        formatter = formatter_for_format(@options[:format])
      else
        formatter = find_formatter { |f| f.extension == File.extname(path) }
      end
      
      unless formatter
        raise Twine::Error.new "Unable to determine format of #{path}. Try using `--format`."
      end      

      lang = lang || formatter.determine_language_given_path(path)
      unless lang
        raise Twine::Error.new "Unable to determine language for #{path}. Try using `--lang`."
      end

      @twine_file.language_codes << lang unless @twine_file.language_codes.include? lang

      return formatter, lang
    end
  end
end
