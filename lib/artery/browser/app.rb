# frozen_string_literal: true

require_relative "../browser"
require "rack"
require "json"

module Artery
  module Browser
    class App
      INDEX_HTML = File.open("#{__dir__}/../../../public/index.html", File::RDONLY).read

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
        %w[/].each do |starting_route|
          router.add_route("GET", starting_route) do |_, _urls|
            [200, { "content-type" => "text/html;charset=utf-8" }, [INDEX_HTML]]
          end
        end

        router.add_route("GET", '/subscriptions') do |_, urls|
          subscriptions = Artery.subscriptions.map do |route, listeners|
            listeners.map do |listener|
              {
                path: route.to_s,
                route: {
                  service: route.service,
                  model: route.model,
                  action: route.action,
                  plural: route.plural
                },
                listener: listener.info.attributes.merge('synchronize' => listener.synchronize?)
              }
            end
          end

          json(subscriptions.flatten)
        end
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
        [200, { "content-type" => "application/vnd.api+json" }, [JSON.dump(body)]]
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
