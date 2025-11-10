# frozen_string_literal: true

require 'artery/browser/version'

module Artery
  module Browser
    class Error < StandardError; end

    require_relative 'browser/router'
  end
end
