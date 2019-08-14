require 'middleman-core/extension'

module Rack
  class TrailingSlashes
    attr_reader :root_path

    def initialize(app)
      @app = app
      @root_path = ::File.expand_path('../source', __dir__)
    end

    def dir_exists?(request_path)
      global = root_path + request_path
      localized = root_path + '/localizable' + request_path

      Dir.exists?(global) || Dir.exists?(localized)
    end

    def call(env)
      request_path = URI.decode(env['PATH_INFO'].dup)

      if dir_exists?(request_path) && request_path[-1] != '/'
        [301, { 'Location' => request_path + '/', 'Content-Type' => 'text/html' }, ['Moved Permanently']]
      else
        @app.call(env)
      end
    end
  end
end
