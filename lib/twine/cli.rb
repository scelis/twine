require 'optparse'
require 'io/console'

module Twine
  module CLI
    ALL_FORMATS = Formatters.formatters.map(&:format_name).map(&:downcase)
    OPTIONS = {
      consume_all: {
        switch: ['-a', '--[no-]consume-all'],
        description: 'Normally Twine will ignore any translation keys that do not exist in your Twine file.',
        boolean: true
      },
      consume_comments: {
        switch: ['-c', '--[no-]consume-comments'],
        description: <<-DESC,
          Normally Twine will ignore all comments in the file. With this flag set, any 
          comments encountered will be read and parsed into the Twine data file. This is especially useful 
          when creating your first Twine data file from an existing project.
        DESC
        boolean: true
      },
      create_folders: {
        switch: ['-r', '--[no-]create-folders'],
        description: <<-DESC,
          This flag may be used to create output folders for all languages, if they don't exist yet.
          As a result all languages will be exported, not only the ones where an output folder already exists.
        DESC
        boolean: true
      },
      developer_language: {
        switch: ['-d', '--developer-language LANG'],
        description: <<-DESC,
          When writing the Twine data file, set the specified language as the "developer language". In 
          practice, this just means that this language will appear first in the Twine data file. When 
          generating files this language will be used as default language and its translations will be 
          used if a definition is not localized for the output language.
        DESC
      },
      encoding: {
        switch: ['-e', '--encoding ENCODING'],
        description: <<-DESC,
          Twine defaults to encoding all output files in UTF-8. This flag will tell Twine to use an alternate
          encoding for these files. For example, you could use this to write Apple .strings files in UTF-16. 
          When reading files, Twine does its best to determine the encoding automatically. However, if the 
          files are UTF-16 without BOM, you need to specify if it's UTF-16LE or UTF16-BE.
        DESC
      },
      file_name: {
        switch: ['-n', '--file-name FILE_NAME'],
        description: 'This flag may be used to overwrite the default file name of the format.'
      },
      format: {
        switch: ['-f', '--format FORMAT', ALL_FORMATS],
        description: <<-DESC,
          The file format to read or write: (#{ALL_FORMATS.join(', ')}). Additional formatters can be placed in the formats/ directory.
        DESC
      },
      languages: {
        switch: ['-l', '--lang LANGUAGES', Array],
        description: 'Comma separated list of language codes to use for the specified action.'
      },
      output_path: {
        switch: ['-o', '--output-file OUTPUT_FILE'],
        description: 'Write a new Twine file at this location instead of replacing the original file.'
      },
      pedantic: {
        switch: ['-p', '--[no-]pedantic'],
        description: 'When validating a Twine file, perform additional checks that go beyond pure validity (like presence of tags).'
      },
      quiet: {
        switch: ['-q', '--[no-]quiet'],
        description: 'Suppress all console output except error messages.'
      },
      validate: {
        switch: ['--[no-]validate'],
        description: 'Validate the Twine file before formatting it.'
      }
    }

    COMMANDS = {
      'generate-all-localization-files' => {
        description: 'Generates all the localization files necessary for a given project. The parent directory to all of the locale-specific directories in your project should be specified as the INPUT_OR_OUTPUT_PATH. This command will most often be executed by your build script so that each build always contains the most recent translations.',
        arguments: [:twine_file, :output_path],
        optional_options: [
          :create_folders,
          :developer_language,
          :encoding,
          :file_name,
          :format,
          :quiet,
          :validate
        ],
        example: 'twine generate-all-localization-files twine.txt Resources/Locales/ --tags FT,FB'
      },
      'validate-twine-file' => {
        description: 'Validates that the given Twine file is parseable, contains no duplicates, and that no key contains invalid characters. Exits with a non-zero exit code if those criteria are not met.',
        arguments: [:twine_file],
        optional_options: [
          :developer_language,
          :pedantic,
          :quiet
        ],
        example: 'twine validate-twine-file twine.txt'
      }
    }
    DEPRECATED_COMMAND_MAPPINGS = {
      'generate-loc-drop' => 'generate-localization-archive',   # added on 17.01.2017 - version 0.10
      'consume-loc-drop' => 'consume-localization-archive'      # added on 17.01.2017 - version 0.10
    }

    def self.parse(args)
      command = args.select { |a| a[0] != '-' }[0]
      args = args.reject { |a| a == command }

      if args.any? { |a| a == '--version' }
        Twine::stdout.puts "Twine version #{Twine::VERSION}"
        return false
      end

      mapped_command = DEPRECATED_COMMAND_MAPPINGS[command]
      if mapped_command
        Twine::stdout.puts "WARNING: Twine commands names have changed. `#{command}` is now `#{mapped_command}`. The old command is deprecated and will soon stop working. For more information please check the documentation at https://github.com/mobiata/twine"
        command = mapped_command
      end

      if command.nil?
        print_help(args)
        return false
      elsif not COMMANDS.keys.include? command
        raise Twine::Error.new "Invalid command: #{command}"
      end

      parse_command_options(command, args)
    end

    private

    def self.print_help(args)
      verbose = false

      help_parser = OptionParser.new
      help_parser.banner = 'Usage: twine [command] [options]'

      help_parser.define('-h', '--help', 'Show this message.')
      help_parser.define('--verbose', 'More detailed help.') { verbose = true }

      help_parser.parse!(args)

      Twine::stdout.puts help_parser.help
      Twine::stdout.puts ''
      

      Twine::stdout.puts 'Commands:'

      COMMANDS.each do |name, properties|
        if verbose
          Twine::stdout.puts ''
          Twine::stdout.puts ''
          Twine::stdout.puts "# #{name}"
          Twine::stdout.puts ''
          Twine::stdout.puts properties[:description]
        else 
          Twine::stdout.puts "- #{name}"
        end
      end

      Twine::stdout.puts ''
      Twine::stdout.puts 'type `twine [command] --help` for further information about a command.'
    end

    # source: https://www.safaribooksonline.com/library/view/ruby-cookbook/0596523696/ch01s15.html
    def self.word_wrap(s, width)
      s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").rstrip
    end

    def self.indent(string, first_line, following_lines)
      lines = string.split("\n")
      indentation = ' ' * following_lines
      lines.map! { |line| indentation + line }
      result = lines.join("\n").strip
      ' ' * first_line + result
    end

    # ensure the description forms a neat block on the right
    def self.prepare_description!(options, summary_width)
      lines = options[:description].split "\n"

      # remove leadinge HEREDOC spaces
      space_match = lines[0].match(/^\s+/)
      if space_match
        leading_spaces = space_match[0].length
        lines.map! { |l| l[leading_spaces..-1] }  
      end

      merged_lines = []
      lines.each do |line|
        # if the line is a continuation of the previous one
        if not merged_lines.empty? and (line[0] != ' ' or line[0, 4] == '    ')
          merged_lines[-1] += ' ' + line.strip
        else
          merged_lines << line.rstrip
        end
      end

      if IO.console
        console_width = IO.console.winsize[1]
      else
        console_width = 100
      end
      summary_width += 7  # account for description padding
      max_description_width = console_width - summary_width
      merged_lines.map! do |line|
        if line[0] == ' '
          line = word_wrap(line.strip, max_description_width - 2)
          line = indent(line, 2, 4)
        else
          line = word_wrap(line, max_description_width)
        end
        line
      end

      options[:switch] << indent(merged_lines.join("\n"), 0, summary_width)
    end

    def self.parse_command_options(command_name, args)
      command = COMMANDS[command_name]

      result = {
        command: command_name
      }

      parser = OptionParser.new
      parser.banner = "Usage: twine #{command_name} #{command[:arguments].map { |c| "[#{c}]" }.join(' ')} [options]"

      [:required_options, :optional_options].each do |option_type|
        options = command[option_type]
        if options and options.size > 0
          parser.separator ''
          parser.separator option_type.to_s.gsub('_', ' ').capitalize + ":"
          
          options.each do |option_name|
            option = OPTIONS[option_name]

            result[option_name] = option[:default] if option[:default]

            prepare_description!(option, parser.summary_width)

            parser.define(*option[:switch]) do |value|
              if option[:repeated]
                result[option_name] = (result[option_name] || []) << value
              else
                result[option_name] = value
              end
            end
          end
        end
      end

      parser.define('-h', '--help', 'Show this message.') do
        Twine::stdout.puts parser.help
        return false
      end

      parser.separator ''
      parser.separator 'Examples:'
      parser.separator ''
      parser.separator "> #{command[:example]}"

      begin
        parser.parse! args
      rescue OptionParser::ParseError => e
        raise Twine::Error.new e.message
      end

      arguments = args.reject { |a| a[0] == '-' }
      number_of_missing_arguments = command[:arguments].size - arguments.size
      if number_of_missing_arguments > 0
        missing_arguments = command[:arguments][-number_of_missing_arguments, number_of_missing_arguments]
        raise Twine::Error.new "#{number_of_missing_arguments} missing argument#{number_of_missing_arguments > 1 ? "s" : ""}: #{missing_arguments.join(', ')}. Check `twine #{command_name} -h`"
      end

      if args.length > command[:arguments].size
        raise Twine::Error.new "Unknown argument: #{args[command[:arguments].size]}"
      end

      if command[:required_options]
        command[:required_options].each do |option_name|
          if result[option_name] == nil
            raise Twine::Error.new "missing option: #{OPTIONS[option_name][:switch][0]}"
          end
        end
      end

      command[:option_validation].call(result) if command[:option_validation]

      command[:arguments].each do |argument_name|
        result[argument_name] = args.shift
      end

      result
    end
  end
end
