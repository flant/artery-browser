require "artery/browser/version"

module Artery
  module Browser
    class Error < StandardError; end
    # Your code goes here...

    require_relative "browser/urls"
    require_relative "browser/router"
  end
end
