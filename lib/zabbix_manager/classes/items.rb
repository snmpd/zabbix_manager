# frozen_string_literal: true

class ZabbixManager
  class Items < Basic
    # The method name used for interacting with Items via Zabbix API
    #
    # @return [String]
    def method_name
      "item"
    end

    # The id field name used for identifying specific Item objects via Zabbix API
    #
    # @return [String]
    def identify
      "name"
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
        snmp_community:        "",
        snmp_oid:              "",
        value_type:            3,
        data_type:             0,
        trapper_hosts:         "localhost",
        snmp_port:             161,
        units:                 "",
        multiplier:            0,
        delta:                 0,
        snmpv3_securityname:   "",
        snmpv3_securitylevel:  0,
        snmpv3_authpassphrase: "",
        snmpv3_privpassphrase: "",
        formula:               0,
        trends:                86_400,
        logtimefmt:            "",
        valuemapid:            0,
        delay_flex:            "",
        authtype:              0,
        username:              "",
        password:              "",
        publickey:             "",
        privatekey:            "",
        params:                "",
        ipmi_sensor:           ""
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

    # ???????????????????????????????????????????????? | 15809 | GigabitEthernet1/0/12
    def get_interface_items(hostid, name)
      # ??????????????????????????????
      _name = name&.gsub(%r{[^/0-9]}, "")&.strip
      iface = "#{_name}("

      # ??????????????????????????????????????????????????????????????? snmp_oid
      result = @client.api_request(
        method: "item.get",
        params: {
          # output:  ["itemid", "name", "snmp_oid", "key_", "triggerids"],
          output:  "extend",
          hostids: hostid,
          search:  {
            name: iface
          }
        }
      ).select {
        |item| item["snmp_oid"].match?(/(1.3.6.1.2.1.31.1.1.1.(6|10|15)|1.3.6.1.2.1.2.2.1.8)./)
      }.sort_by {
        |item| item["key_"]
      }

      # ?????????????????????
      result.empty? ? nil : result
    end

    # ???????????? dns item
    def create_dns_item(hostid, dns_name)
      # ????????????
      item_name = "???DNS?????????????????????#{dns_name}"
      item_key_ = "net.dns.record[,#{dns_name},A,2,2]"

      # ???????????? dns ????????????????????? hostid
      result = @client.api_request(
        method: "item.create",
        params: {
          hostid: hostid,
          name:   item_name,
          key_:   item_key_,
          # ?????? zabbix_agent
          type: 0,
          # ???????????????
          value_type: 1,
          # ????????????
          delay:    "1m",
          history:  "90d",
          lifetime: "30d",
          timeout:  "3s"
        }
      )
      p "???????????? dns?????? #{dns_name}"
    rescue StandardError
      p "?????? dns?????? #{dns_name} ??????"
    end

    # ?????????????????????????????????
    def get_item_info
      result = @client.api_request(
        method: "item.get",
        params: {
          output:  "extend",
          hostids: "16914"
        }
      )
    end
  end
end
