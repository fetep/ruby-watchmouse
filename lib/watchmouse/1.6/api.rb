require "rubygems"
require "bundler/setup"

require "watchmouse/error"
require "rest_client"
require "json"
require "yaml"
require "uri"

module Watchmouse
  class Ver16
    class API
      URL_BASE = "https://api.watchmouse.com/1.6/"

      GET_CALLS = [:acct_logout, :acct_noop, :rule_check, :rule_get,
                   :rule_log]
      POST_CALLS = []

      public
      def initialize(user, password, cookie_jar_path = nil)
        @user, @password = user, password
        @cookie_jar_path = cookie_jar_path
        @cookies = nil
        if @cookie_jar_path && File.exists?(@cookie_jar_path)
          @cookies = YAML.load_file(@cookie_jar_path)
        end
      end # def initialize

      public
      def acct_login
        post("acct_login", {:user => @user, :password => @password})
      end # def acct_login
      alias :login :acct_login

      private
      def get(endpoint, params = {})
        params[:callback] = "_"
        url = URI.join(URL_BASE, endpoint.to_s)
        url.query = params.collect do |k, v|
          "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}"
        end.join("&")
        res = RestClient.get(url.to_s, {:cookies => @cookies})

        begin
          # JSONP-style "_({json})" -> "{json}" -> data structure
          data = JSON.parse(res.body[2..-3])
        rescue JSON::ParserError
          debug "raw JSON: #{res.body[2..-3]}"
          raise Watchmouse::Error, "trouble parsing JSON from #{url}: #{$!}"
        end

        if data["code"] == 1000 or data["code"] == 1008
          # login issue
          debug "#{url} returned code=#{data["code"]}, forcing acct_login"
          acct_login
          return get(endpoint, params)
        elsif data["code"] != 0
          raise Watchmouse::Error, "get to #{url.to_s} " \
                "failed, code=#{data["code"]} error=#{data["error"]}"
        end

        return data["result"]
      end # def get

      public
      def method_missing(method, *params)
        if GET_CALLS.member?(method)
          get(method, *params)
        elsif POST_CALLS.member?(method)
          post(method, *params)
        else
          super
        end
      end

      private
      def post(endpoint, params = {})
        params[:callback] = "_"
        url = URI.join(URL_BASE, endpoint.to_s)
        if endpoint == "acct_login"
          # don't pass old cookies when logging in
          res = RestClient.post(URL_BASE + endpoint, params)
        else
          res = RestClient.post(URL_BASE + endpoint, params,
                                {:cookies => @cookies})
        end

        begin
          # JSONP-style "_({json})" -> "{json}" -> data structure
          data = JSON.parse(res.body[2..-3])
        rescue JSON::ParserError
          debug "raw JSON: #{res.body[2..-3]}"
          raise Watchmouse::Error, "trouble parsing JSON from #{url}: #{$!}"
        end

        if data["code"] == 1000 and endpoint != "acct_login"
          # we need to login!
          debug "#{url} returned code=1000, forcing acct_login"
          acct_login
          return post(endpoint, params)  # retry the post
        elsif data["code"] == 1008
          # expired session cookies
          debug "#{url} returned code=1008, forcing acct_login"
          acct_login
        elsif data["code"] != 0
          raise Watchmouse::Error, "post to #{url} with #{params.inspect} " \
                "failed, code=#{data["code"]} error=#{data["error"]}"
        end

        if res.cookies != @cookies
          debug "cookies changed. old=#{@cookies.inspect} " \
                "new=#{res.cookies.inspect}"
          @cookies = res.cookies

          if @cookie_jar_path
            File.open(@cookie_jar_path, "w+") { |f| f.puts @cookies.to_yaml }
          end
        end

        return data["result"]
      end # def post

      private
      def debug(msg)
        if $DEBUG
          $stderr.puts "Watchmouse::API: #{msg}"
        end
      end # def debug
    end # class API
  end # class Ver16
end # module Watchmouse
