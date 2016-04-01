Dir[File.join(File.dirname(__FILE__), 'transformers', '*.rb')].each do |file|
  require file
end
