require 'net/http'
require 'json'
require 'Open3'

module Twine
  module Transformers
=begin
    class MicrosoftTranslator
      attr_reader :auth_url
      attr_reader :auth_params
      attr_reader :array_url

      def initialize(auth_url, auth_params, array_url)
        @auth_url = URI(auth_url)
        @auth_params = auth_params
        @array_url = array_url

      def translate_dict(dict_key_text, from_language, to_language, settings_dict)
        response = JSON.parse(Net::HTTP.post_form(@auth_url, @auth_params).body)
        access_token = response["access_token"]

        if access_token == nil || access_token == ""
          raise Twine::Error.new("Unable to retrieve access token from MS translator")
        end

        keys, texts = dict_key_text.to_a.transpose

        options = { "Category" => "general",
                    "Contenttype" => "text/plain",
                    "Uri" => "",
                    "User" => "default",
                    "State": ""
                  }
        params = { "from" => from_language || "en",
                   "texts" => JSON.generate(texts)
                   "to" => to_language
                   "options" => JSON.generate(options)
                 }
        uri = URI(array_url + "/TranslateArray")
        header = { "Authorization" => "Bearer " + access_token}
        uri.query = URI.encode_www_form(params)
        translate_response = Net::HTTP.get(uri, initheader = header)
        translate_json = JSON.parse(translate_response.body)
        puts translate_json
        return {}
      end

    end
=end

    class PythonTranslator
      def translate_dict(dict_key_text, from_language, to_language, script)
        keys, texts = dict_key_text.to_a.transpose
        payload = {
          "to_language" => to_language,
          "from_language" => from_language,
          "texts" => texts
        }
        param = JSON.generate payload
        #puts param
        in_pipe = 'rp_pipe'
        out_pipe = 'pr_pipe'
        `mkfifo #{in_pipe}`
        `mkfifo #{out_pipe}`
        begin
          path = File.expand_path("~/code/twistle/health/test3.json")
          out_path = File.expand_path("~/code/twistle/health/test3_out.json")
          File.open(path, File::CREAT|File::WRONLY) { |file| file.write param }

          #cmd = `#{script} < #{path} > #{out_path}`
          cmd = `#{script} <(#{param}) > #{out_path}`
=begin
          output, errors, status = Open3.popen3(cmd) { |i, o, e, t|
            #i.close
            out_reader = Thread.new { o.readlines }
            err_reader = Thread.new { e.read }
            #i.set_encoding(param.encoding)
            #i.write param
            #i.close
            [out_reader.value, err_reader.value, t.value]
          }
          puts status
=end
          #puts ""
          #output.each {|s| puts s}
          #puts output
          output = File.open(out_path, File::RDONLY) { |file| file.read }
          #puts output
          #puts errors if output == nil || output == ""

          result = JSON.parse output #if errors == ""
          puts result
        ensure
          `rm #{in_pipe}`
          `rm #{out_pipe}`
        end
      end
    end
  end
end

Twine::Transformers.transformers << Twine::Transformers::PythonTranslator.new
