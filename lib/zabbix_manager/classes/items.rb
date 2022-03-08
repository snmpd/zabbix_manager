class ZabbixManager
  class Items < Basic
    # The method name used for interacting with Items via Zabbix API
    #
    # @return [String]
    def method_name
      'item'
    end

    # The id field name used for identifying specific Item objects via Zabbix API
    #
    # @return [String]
    def identify
      'name'
    end

    # The default options used when creating Item objects via Zabbix API
    #
    # @return [Hash]
    def default_options
      {
        name:                  nil,
        key_:                  nil,
        hostid:                nil,
        delay:                 60,
        history:               3600,
        status:                0,
        type:                  7,
        snmp_community:        '',
        snmp_oid:              '',
        value_type:            3,
        data_type:             0,
        trapper_hosts:         'localhost',
        snmp_port:             161,
        units:                 '',
        multiplier:            0,
        delta:                 0,
        snmpv3_securityname:   '',
        snmpv3_securitylevel:  0,
        snmpv3_authpassphrase: '',
        snmpv3_privpassphrase: '',
        formula:               0,
        trends:                86400,
        logtimefmt:            '',
        valuemapid:            0,
        delay_flex:            '',
        authtype:              0,
        username:              '',
        password:              '',
        publickey:             '',
        privatekey:            '',
        params:                '',
        ipmi_sensor:           ''
      }
    end

    # Get or Create Item object using Zabbix API
    #
    # @param data [Hash] Needs to include name and hostid to properly identify Items via Zabbix API
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Zabbix object id
    def get_or_create(data)
      log "[DEBUG] Call get_or_create with parameters: #{data.inspect}"

      unless (id = get_id(name: data[:name], hostid: data[:hostid]))
        id = create(data)
      end
      id
    end

    # Create or update Item object using Zabbix API
    #
    # @param data [Hash] Needs to include name and hostid to properly identify Items via Zabbix API
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Zabbix object id
    def create_or_update(data)
      itemid = get_id(name: data[:name], hostid: data[:hostid])
      itemid ? update(data.merge(itemid: itemid)) : create(data)
    end

    # 根据设备名称和接口名字查询监控项 | 15809 | GigabitEthernet1/0/12
    def get_interface_items(hostid, name)
      # 自动剔除收尾空白字串
      _name = name&.gsub(%r"[^\/0-9]", "")&.strip
      iface = "#{_name}("

      # 模糊查询接口下所有监控项，同时过滤出特定的 snmp_oid
      result = @client.api_request(
        method: 'item.get',
        params: {
          # output:  ["itemid", "name", "snmp_oid", "key_", "triggerids"],
          output:  'extend',
          hostids: hostid,
          search:  {
            name: iface
          },
        }
      ).select { |item| item["snmp_oid"].match?(/1.3.6.1.2.1.31.1.1.1.(6|10)./) }

      # 检查是是否存在
      result.empty? ? nil : result
    end

    # 创建单个 dns item
    def create_dns_item(hostid, dns_name)
      # 字串内插
      item_name = "【DNS域名解析监控】#{dns_name}"
      item_key_ = "net.dns.record[,#{dns_name},A,2,2]"

      # 请求绑定 dns 监控项到特定的 hostid
      result = @client.api_request(
        method: 'item.create',
        params: {
          hostid: hostid,
          name:   item_name,
          key_:   item_key_,
          # 代表 zabbix_agent
          type: 0,
          # 代表字符串
          value_type: 1,
          # 固定参数
          delay:    "1m",
          history:  "90d",
          lifetime: "30d",
          timeout:  "3s",
        }
      )
      p "成功创建 dns监控 #{dns_name}"
    rescue
      p "创建 dns监控 #{dns_name} 异常"
    end

    # 查询某个监控项具体信息
    def get_item_info
      result = @client.api_request(
        method: 'item.get',
        params: {
          output:  "extend",
          hostids: "16914",
        }
      )
    end
  end
end
