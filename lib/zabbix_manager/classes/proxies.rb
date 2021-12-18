class ZabbixManager
  class Proxies < Basic
    # The method name used for interacting with Proxies via Zabbix API
    #
    # @return [String]
    def method_name
      'proxy'
    end

    # The id field name used for identifying specific Proxy objects via Zabbix API
    #
    # @return [String]
    def identify
      'host'
    end

    # Delete Proxy object using Zabbix API
    #
    # @param data [Array] Should include array of proxyid's
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] The Proxy object id that was deleted
    def delete(data)
      result = @client.api_request(method: 'proxy.delete', params: data)
      result.empty? ? nil : result['proxyids'][0].to_i
    end

    # Check if a Proxy object is readable using Zabbix API
    #
    # @param data [Array] Should include array of proxyid's
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Boolean] Returns true if the given proxies are readable
    def isreadable(data)
      @client.api_request(method: 'proxy.isreadable', params: data)
    end

    # Check if a Proxy object is writable using Zabbix API
    #
    # @param data [Array] Should include array of proxyid's
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Boolean] Returns true if the given proxies are writable
    def iswritable(data)
      @client.api_request(method: 'proxy.iswritable', params: data)
    end

    # 新增代理服务器查询接口
    def get_proxy_id(proxy)
      # 边界条件判断
      return nil if proxy.nil?

      # 请求后端接口，只支持单个代理节点
      result = @client.api_request(
        method: 'proxy.get',
        params: {
          output: "extend",
          filter: {
            host: proxy
          }
        }
      )

      # 返回代理节点
      result.empty? ? nil : result[0]["proxyid"]
    end
  end
end
