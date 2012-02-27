require "rubygems"
require "bundler/setup"

require "watchmouse/1.6/api"

module Watchmouse
  class API
    VERSION_MAP = {
      "latest" => Ver16::API,
      "1.6"    => Ver16::API,
    }

    def self.new(version, *args)
      klass = VERSION_MAP[version]
      if klass.nil?
        raise Error, "Unknown API version, #{version}"
      end

      klass.new(*args)
    end # def self.new
  end # class API
end # module Watchmouse
