# frozen_string_literal: true

module Artery
  module Browser
    class Urls
      def self.from_configuration(host, root_path, api_url = nil)
        new(host, root_path, api_url)
      end

      def self.initial
        new(nil, nil, nil)
      end

      def with_request(request)
        Urls.new(host || request.base_url, root_path || request.script_name, api_url)
      end

      attr_reader :app_url, :api_url, :host, :root_path

      def initialize(host, root_path, api_url)
        @host = host
        @root_path = root_path
        @app_url = [host, root_path].compact.reduce(:+)
        @api_url = api_url || ("#{app_url}/api" if app_url)
      end

      def ==(o)
        self.class.eql?(o.class) && app_url.eql?(o.app_url) && api_url.eql?(o.api_url)
      end

      private

      def local_file_url(name)
        "#{app_url}/#{name}"
      end
    end
  end
end
