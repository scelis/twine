module TwineFileDSL
  def build_twine_file(*languages)
    @currently_built_twine_file = Twine::TwineFile.new
    @currently_built_twine_file.language_codes.concat languages
    yield
    result = @currently_built_twine_file
    @currently_built_twine_file = nil
    return result
  end

  def add_section(name)
    return unless @currently_built_twine_file
    @currently_built_twine_file_section = Twine::TwineSection.new name
    @currently_built_twine_file.sections << @currently_built_twine_file_section
    yield
    @currently_built_twine_file_section = nil
  end

  def add_definition(parameters)
    return unless @currently_built_twine_file
    return unless @currently_built_twine_file_section

    # this relies on Ruby preserving the order of hash elements
    key, value = parameters.first
    definition = Twine::TwineDefinition.new(key.to_s)
    if value.is_a? Hash
      value.each do |language, translation|
        definition.translations[language.to_s] = translation
      end
    elsif !value.is_a? Symbol
      language = @currently_built_twine_file.language_codes.first
      definition.translations[language] = value
    end

    definition.comment = parameters[:comment] if parameters[:comment]
    definition.tags = parameters[:tags] if parameters[:tags]
    if parameters[:ref] || value.is_a?(Symbol)
      reference_key = (parameters[:ref] || value).to_s
      definition.reference_key = reference_key
      definition.reference = @currently_built_twine_file.definitions_by_key[reference_key]
    end

    @currently_built_twine_file_section.definitions << definition
    @currently_built_twine_file.definitions_by_key[definition.key] = definition
  end
end
