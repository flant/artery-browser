# frozen_string_literal: true

require_relative "../browser"
require "rack"
require "json"

module Artery
  module Browser
    class App
      def self.for(host: nil, path: nil, api_url: nil, environment: nil)
        ::Rack::Builder.new do
          use Rack::Static,
            urls:
              %w[
                  index.html
                  logo.svg
                  assets/index-CA3lEEVU.js
                  assets/index-1s3WlefU.css
                ].map { |f| ["/#{f}", f] }.to_h,
            root: "#{__dir__}/../../../public"
          run App.new(
            host: host,
            root_path: path,
            api_url: api_url,
          )
        end
      end

      def initialize(host:, root_path:, api_url:)
        @routing = Urls.from_configuration(host, root_path, api_url)
      end

      def call(env)
        router = Router.new(routing)
        router.handle(::Rack::Request.new(env))
      rescue Router::NoMatch
        not_found
      end

      private

      attr_reader :routing

      def not_found
        [404, {}, []]
      end

      def json(body)
        [200, { "content-type" => "application/vnd.api+json" }, [JSON.dump(body.to_h)]]
      end

      def erb(template, **locals)
        [200, { "content-type" => "text/html;charset=utf-8" }, [ERB.new(template).result_with_hash(locals)]]
      end

      def res_version
        Browser::VERSION
      end
    end
  end
end
