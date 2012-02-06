module Twine
  class StringsSection
    attr_reader :name
    attr_reader :rows

    def initialize(name)
      @name = name
      @rows = []
    end
  end

  class StringsRow
    attr_reader :key
    attr_accessor :comment
    attr_accessor :tags
    attr_reader :translations

    def initialize(key)
      @key = key
      @comment = nil
      @tags = nil
      @translations = {}
    end
  end

  class StringsFile
    attr_reader :sections
    attr_reader :strings_map
    attr_reader :language_codes

    def initialize
      @sections = []
      @strings_map = {}
      @language_codes = []
    end

    def read(path)
      if !File.file?(path)
        raise Twine::Error.new("File does not exist: #{path}")
      end

      File.open(path, 'r:UTF-8') do |f|
        line_num = 0
        current_section = nil
        current_row = nil
        while line = f.gets
          parsed = false
          line.strip!
          line_num += 1

          if line.length == 0
            next
          end

          if line.length > 4 && line[0, 2] == '[['
            match = /^\[\[(.+)\]\]$/.match(line)
            if match
              current_section = StringsSection.new(match[1].strip)
              @sections << current_section
              parsed = true
            end
          elsif line.length > 2 && line[0, 1] == '['
            match = /^\[(.+)\]$/.match(line)
            if match
              current_row = StringsRow.new(match[1].strip)
              @strings_map[current_row.key] = current_row
              if !current_section
                current_section = StringsSection.new('')
                @sections << current_section
              end
              current_section.rows << current_row
              parsed = true
            end
          else
            match = /^([^=]+)=(.+)$/.match(line)
            if match
              key = match[1].strip
              value = match[2].strip
              if value[0,1] == '`' && value[-1,1] == '`'
                value = value[1..-2]
              end

              case key
              when "comment"
                current_row.comment = value
              when 'tags'
                current_row.tags = value.split(',')
              else
                if !@language_codes.include? key
                  @language_codes << key
                end
                current_row.translations[key] = value
              end
              parsed = true
            end
          end

          if !parsed
            raise Twine::Error.new("Unable to parse line #{line_num} of #{path}: #{line}")
          end
        end

        # Developer Language
        dev_lang = @language_codes[0]
        @language_codes.delete(dev_lang)
        @language_codes.sort!
        @language_codes.insert(0, dev_lang)
      end
    end

    def write(path)
      dev_lang = @language_codes[0]

      File.open(path, 'w:UTF-8') do |f|
        @sections.each do |section|
          if f.pos > 0
            f.puts ''
          end

          f.puts "[[#{section.name}]]"

          section.rows.each do |row|
            value = row.translations[dev_lang]
            if value[0,1] == ' ' || value[-1,1] == ' ' || (value[0,1] == '`' && value[-1,1] == '`')
              value = '`' + value + '`'
            end

            f.puts "\t[#{row.key}]"
            f.puts "\t\t#{dev_lang} = #{value}"
            if row.tags && row.tags.length > 0
              tag_str = row.tags.join(',')
              f.puts "\t\ttags = #{tag_str}"
            end
            if row.comment && row.comment.length > 0
              f.puts "\t\tcomment = #{row.comment}"
            end
            @language_codes[1..-1].each do |lang|
              value = row.translations[lang]
              if value && value != row.translations[dev_lang]
                if value[0,1] == ' ' || value[-1,1] == ' ' || (value[0,1] == '`' && value[-1,1] == '`')
                  value = '`' + value + '`'
                end
                f.puts "\t\t#{lang} = #{value}"
              end
            end
          end
        end
      end
    end
  end
end
