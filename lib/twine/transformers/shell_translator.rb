require 'net/http'
require 'json'
require 'Open3'
require 'tempfile'

module Twine
  module Transformers
    class ShellTranslator
      attr_reader :script

      def initialize(script)
        @script = script
      end

      def translate_dict(dict_key_text, from_language, to_language)
        return {} if dict_key_text.empty?
        keys, texts = dict_key_text.to_a.transpose
        payload = {
          "to_language" => to_language,
          "from_language" => from_language,
          "texts" => texts
        }
        param = JSON.generate payload
        req_temp = Tempfile.new('r_to_p')
        res_temp = Tempfile.new('p_to_r')
        err_temp = Tempfile.new('translation_errors')

        translations = []
        begin
          req_temp.write param
          req_temp.close

          `#{script} < #{req_temp.path} > #{res_temp.path} 2> #{err_temp.path}`

          errors = err_temp.read
          err_temp.close
          output = res_temp.read
          res_temp.close

          if errors != ""
            puts errors
          else
            translations = JSON.parse output
          end
        ensure
          req_temp.close true
          res_temp.close true
          err_temp.close true
        end
        result = Hash[keys.zip(translations)]
      end
    end
  end
end
