# frozen_string_literal: true

require "net/http"
require "json"
require "openssl"

class ZabbixManager
  class Client
    # @param (see ZabbixManager::Client#initialize)
    # @return [Hash]
    attr_reader :options

    # @return [Integer]
    def id
      rand 10_000
    end

    # Returns the API version from the Zabbix Server
    #
    # @return [String, Hash]
    def api_version
      api_request(method: "apiinfo.version", params: {})
    end

    # Log in to the Zabbix Server and generate an auth token using the API
    #
    # @return [Hash, String]
    def auth
      api_request(
        method: "user.login",
        params: {
          user: @options[:user],
          password: @options[:password]
        }
      )
    end

    # ZabbixManager::Basic.log does not like @client.options[:debug]
    #
    # @return [boolean]
    def debug?
      !@options || @options[:debug]
    end

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @option opts [String] :url The url of zabbix_manager(example: 'http://localhost/zabbix/api_jsonrpc.php')
    # @option opts [String] :user
    # @option opts [String] :password
    # @option opts [String] :http_user A user for basic auth.(optional)
    # @option opts [String] :http_password A password for basic auth.(optional)
    # @option opts [Integer] :timeout Set timeout for requests in seconds.(default: 60)
    #
    # @return [ZabbixManager::Client]
    def initialize(options = {})
      @options = options
      if !ENV["http_proxy"].nil? && options[:no_proxy] != true
        @proxy_uri               = URI.parse(ENV["http_proxy"])
        @proxy_host              = @proxy_uri.host
        @proxy_port              = @proxy_uri.port
        @proxy_user, @proxy_pass = @proxy_uri.userinfo&.split(/:/) if @proxy_uri.userinfo
      end

      if api_version.match?(/^7\.\d+\.\d+$/)
        message = "Zabbix API version: #{api_version} is not supported by this version of zabbix_manager"
        if @options[:ignore_version]
          puts "[WARNING] #{message}" if @options[:debug]
        else
          raise ZabbixManager::ManagerError, message
        end
      end

      @auth_hash = auth
      puts "[DEBUG] Auth token: #{@auth_hash}" if @options[:debug]
    end

    # Convert message body to JSON string for the Zabbix API
    #
    # @param body [Hash]
    # @return [String]
    def message_json(body)
      message = {
        method: body[:method],
        params: body[:params],
        id: id,
        jsonrpc: "2.0"
      }

      # 除登录认证和获取版本后之外，都需要携带TOKEN查询
      message[:auth] = @auth_hash unless body[:method] == "apiinfo.version" || body[:method] == "user.login"

      JSON(message)
    end

    # @param body [String]
    # @return [String]
    def http_request(body)
      uri = URI.parse(@options[:url])

      # set the time out the default (60) or to what the user passed
      timeout = @options[:timeout].nil? ? 60 : @options[:timeout]
      puts "[DEBUG] Timeout for request set to #{timeout} seconds" if @options[:debug]

      http =
        if @proxy_uri
          Net::HTTP.Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass).new(uri.host, uri.port)
        else
          Net::HTTP.new(uri.host, uri.port)
        end

      if uri.scheme == "https"
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.open_timeout = timeout
      http.read_timeout = timeout

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth @options[:http_user], @options[:http_password] if @options[:http_user]
      request.add_field("Content-Type", "application/json-rpc")
      request.body = body
      puts "[DEBUG] HTTP request params: #{request.body}" if @options[:debug]

      response = http.request(request)
      raise HttpError.new("HTTP Error: #{response.code} on #{@options[:url]}", response) unless response.code == "200"

      puts "[DEBUG] HTTP response answer: #{response.body}" if @options[:debug]
      response.body
    end

    # @param body [String]
    # @return [Hash, String]
    def _request(body)
      result = JSON.parse(http_request(body))
      # 异常信息抛出
      if result["error"]
        raise ManagerError.new(
          "Server answer API error\n #{JSON.pretty_unparse(result["error"])}\n on request:\n #{pretty_body(body)}", result
        )
      end

      result["result"]
    end

    def pretty_body(body)
      parsed_body = JSON.parse(body)

      # If password is in body hide it
      if parsed_body["params"].is_a?(Hash) && parsed_body["params"].key?("password")
        parsed_body["params"]["password"] =
          "***"
      end

      JSON.pretty_unparse(parsed_body)
    end

    # Execute Zabbix API requests and return response
    #
    # @param body [Hash]
    # @return [Hash, String]
    def api_request(body)
      # ap body
      _request message_json(body)
    end
  end
end
