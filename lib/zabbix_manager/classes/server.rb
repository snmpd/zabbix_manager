# frozen_string_literal: true

class ZabbixManager
  class Server
    # @return [String]
    attr_reader :version

    # Initializes a new Server object with ZabbixManager Client and fetches Zabbix Server API version
    #
    # @param client [ZabbixManager::Client]
    # @return [ZabbixManager::Client]
    # @return [String] Zabbix API version number
    def initialize(client)
      @client = client
      @version = @client.api_version
    end
  end
end
