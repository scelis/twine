require 'erb'
require 'minitest/autorun'
require "mocha/mini_test"
require 'securerandom'
require 'twine'
require 'twine_file_dsl'

class TwineTestCase < Minitest::Test
  include TwineFileDSL
  
  def setup
    super
    @output_dir = Dir.mktmpdir
    @output_path = File.join @output_dir, SecureRandom.uuid
  end

  def teardown
    FileUtils.remove_entry_secure @output_dir
    super
  end

  def fixture_path
    'fixtures'
  end

  def output_content
    File.read @output_path
  end

  def execute(command)
    command += "  -o #{@output_path}"
    Twine::Runner.run(command.split(" "))
  end

  def fixture(filename)
    File.join __dir__, fixture_path, filename
  end
  alias :f :fixture

  def content(filename)
    ERB.new(File.read fixture(filename)).result
  end
end
