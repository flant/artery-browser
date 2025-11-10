# frozen_string_literal: true

require_relative '../browser'
require 'rack'
require 'json'

module Artery
  module Browser
    class App
      INDEX_HTML = File.open("#{__dir__}/../../../public/index.html", File::RDONLY).read

      def self.build
        ::Rack::Builder.new do
          use Rack::Static,
              urls:
                %w[
                  index.html
                  logo.svg
                  assets/index-CFTHRyuc.js
                  assets/index-Dw-hdo5G.css
                  assets/validate-routes-Cx95rB3S.js
                ].map { |f| ["/#{f}", f] }.to_h,
              root: "#{__dir__}/../../../public"
          run App.new
        end
      end

      def initialize; end

      def call(env)
        router = Router.new
        %w[/].each do |starting_route|
          router.add_route('GET', starting_route) do |_params, _request|
            [200, { 'content-type' => 'text/html;charset=utf-8' }, [INDEX_HTML]]
          end
        end

        router.add_route('GET', '/subscriptions') do |_params, _request|
          json((Artery.subscriptions || {}).map do |route, listeners|
            {
              path: route.to_s,
              service: route.service,
              model: route.model,
              action: route.action,
              plural: route.plural,
              listeners: listeners.map do |listener|
                listener.info.attributes.merge(
                  source: listener.source?,
                  latest_outgoing_message_index: listener.latest_outgoing_message_index
                )
              end
            }
          end)
        end

        router.add_route('PUT', '/listeners/:listener_id') do |params, request|
          listener = Artery.subscription_info_class.find(params.fetch('listener_id'))
          updates = JSON.parse(request.body.gets).slice('latest_index')
          listener.update!(updates)
          Artery.subscriptions.each_value do |listeners|
            listeners.each do |subscription_listener|
              subscription_listener.info.reload if subscription_listener.info == listener
            end
          end

          json(listener.attributes)
        end

        router.handle(::Rack::Request.new(env))
      rescue Router::NoMatch
        not_found
      end

      private

      def not_found
        [404, {}, []]
      end

      def json(body)
        [200, { 'content-type' => 'application/vnd.api+json' }, [JSON.dump(body)]]
      end

      def erb(template, **locals)
        [200, { 'content-type' => 'text/html;charset=utf-8' }, [ERB.new(template).result_with_hash(locals)]]
      end

      def res_version
        Browser::VERSION
      end
    end
  end
end
