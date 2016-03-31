require 'net/http'
require 'json'
require 'Open3'
require 'tempfile'

module Twine
  module Transformers
    class PythonTranslator
      def translate_dict(dict_key_text, from_language, to_language, script)
        keys, texts = dict_key_text.to_a.transpose
        payload = {
          "to_language" => to_language,
          "from_language" => from_language,
          "texts" => texts
        }
        param = JSON.generate payload

        req_temp = Tempfile.new('r-to-p')
        res_temp = Tempfile.new('p-to-r')

        begin

          req_temp.write param
          req_temp.close

          `#{script} < #{req_temp.path} > #{res_temp.path}`

          output = res_temp.read

          res_temp.close

          result = JSON.parse output #if errors == ""
          #puts result
        ensure
          req_temp.close true
          res_temp.close true
        end
      end
    end
  end
end

Twine::Transformers.transformers << Twine::Transformers::PythonTranslator.new
