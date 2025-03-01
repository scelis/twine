module Twine
  module Placeholders
    extend self

    # Note: the ` ` (single space) flag is NOT supported
    PLACEHOLDER_FLAGS_WIDTH_PRECISION_LENGTH = '([-+0#])?(\d+|\*)?(\.(\d+|\*))?(hh?|ll?|L|z|j|t|q)?'
    PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH = '(\d+\$)?' + PLACEHOLDER_FLAGS_WIDTH_PRECISION_LENGTH
    PLACEHOLDER_TYPES = '[diufFeEgGxXoscpaA]'
    PLACEHOLDER_REGEX = /%#{PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH}#{PLACEHOLDER_TYPES}/

    def number_of_twine_placeholders(input)
      input.scan(PLACEHOLDER_REGEX).size
    end

    def convert_twine_string_placeholder(input)
      # %@ -> %s
      input.gsub(/(%#{PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH})@/, '\1s')
    end

    # http://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling
    # http://stackoverflow.com/questions/4414389/android-xml-percent-symbol
    # https://github.com/mobiata/twine/pull/106
    def convert_placeholders_from_twine_to_android(input)
      # %@ -> %s
      value = convert_twine_string_placeholder(input)

      number_of_placeholders = number_of_twine_placeholders(value)

      return value if number_of_placeholders == 0

      # got placeholders -> need to double single percent signs
      # % -> %% (but %% -> %%, %d -> %d)
      placeholder_syntax = PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH + PLACEHOLDER_TYPES
      single_percent_regex = /([^%])(%)(?!(%|#{placeholder_syntax}))/
      value.gsub! single_percent_regex, '\1%%'

      return value if number_of_placeholders < 2

      # number placeholders
      non_numbered_placeholder_regex = /%(#{PLACEHOLDER_FLAGS_WIDTH_PRECISION_LENGTH}#{PLACEHOLDER_TYPES})/

      number_of_non_numbered_placeholders = value.scan(non_numbered_placeholder_regex).size

      return value if number_of_non_numbered_placeholders == 0

      raise Twine::Error.new("The value \"#{input}\" contains numbered and non-numbered placeholders") if number_of_placeholders != number_of_non_numbered_placeholders

      # %d -> %$1d
      index = 0
      value.gsub!(non_numbered_placeholder_regex) { "%#{index += 1}$#{$1}" }

      value
    end

    def convert_placeholders_from_android_to_twine(input)
      placeholder_regex = /(%#{PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH})s/

      # %s -> %@
      input.gsub(placeholder_regex, '\1@')
    end

    # http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/resources/IResourceManager.html#getString()
    # http://soenkerohde.com/2008/07/flex-localization/comment-page-1/
    def convert_placeholders_from_twine_to_flash(input)
      value = convert_twine_string_placeholder(input)

      value.gsub(PLACEHOLDER_REGEX).each_with_index do |match, index|
        "{#{index}}"
      end
    end

    def convert_placeholders_from_flash_to_twine(input)
      input.gsub(/\{\d+\}/, '%@')
    end

    # Python supports placeholders in the form of `%(amount)03d`
    # see https://docs.python.org/3/library/stdtypes.html#printf-style-string-formatting
    def contains_python_specific_placeholder(input)
      /%\([a-zA-Z0-9_-]+\)#{PLACEHOLDER_PARAMETER_FLAGS_WIDTH_PRECISION_LENGTH}#{PLACEHOLDER_TYPES}/.match(input) != nil
    end
  end
end
