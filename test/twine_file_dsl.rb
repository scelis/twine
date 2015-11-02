module TwineFileDSL
  def build_twine_file(*languages)
    @currently_built_twine_file = Twine::StringsFile.new
    @currently_built_twine_file.language_codes.concat languages
    yield
    result = @currently_built_twine_file
    @currently_built_twine_file = nil
    return result
  end

  def add_section(name)
    return unless @currently_built_twine_file
    @currently_built_twine_file_section = Twine::StringsSection.new name
    @currently_built_twine_file.sections << @currently_built_twine_file_section
    yield
    @currently_built_twine_file_section = nil
  end

  def add_row(parameters)
    return unless @currently_built_twine_file
    return unless @currently_built_twine_file_section

    # this relies on Ruby 1.9 preserving the order of hash elements
    row = Twine::StringsRow.new(parameters.first[0].to_s)
    if parameters.first[1].is_a? Hash
      parameters.first[1].each do |language, translation|
        row.translations[language.to_s] = translation
      end
    else
      language = @currently_built_twine_file.language_codes.first
      row.translations[language] = parameters.first[1]
    end
    row.comment = parameters[:comment] if parameters[:comment]
    row.tags = parameters[:tags] if parameters[:tags]

    @currently_built_twine_file_section.rows << row
    @currently_built_twine_file.strings_map[row.key] = row
  end
end
