class ZabbixManager
  class Hosts < Basic
    # The method name used for interacting with Hosts via Zabbix API
    #
    # @return [String]
    def method_name
      'host'
    end

    # The id field name used for identifying specific Host objects via Zabbix API
    #
    # @return [String]
    def identify
      'host'
    end

    # Dump Host object data by key from Zabbix API
    #
    # @param data [Hash] Should include desired object's key and value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def dump_by_id(data)
      log "[DEBUG] Call dump_by_id with parameters: #{data.inspect}"
      @client.api_request(
        method: 'host.get',
        params: {
          filter: {
            key.to_sym => data[key.to_sym]
          },
          output: 'extend',
          # selectHosts: 'shorten'
        }
      )
    end

    # The default options used when creating Host objects via Zabbix API
    #
    # @return [Hash]
    def default_options
      {
        host:           nil,
        interfaces:     {
          main:    1,
          useip:   1,
          type:    2,
          ip:      nil,
          dns:     "",
          port:    161,
          details: {
            version:   2,
            community: "transsion"
          }
        },
        status:         0,
        available:      1,
        groups:         [],
        proxy_hostid:   nil,
        inventory_mode: 1
      }
    end

    # Unlink/Remove Templates from Hosts using Zabbix API
    #
    # @param data [Hash] Should include hosts_id array and templates_id array
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Boolean]
    def unlink_templates(data)
      result = @client.api_request(
        method: 'host.massRemove',
        params: {
          hostids:   data[:hosts_id],
          templates: data[:templates_id]
        }
      )
      result.empty? ? false : true
    end

    # Create or update Host object using Zabbix API
    #
    # @param data [Hash] Needs to include host to properly identify Hosts via Zabbix API
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Zabbix object id

    # 根据主机 hostid 获取 interfaceid
    def get_interface_id(hostid)
      log "[DEBUG] Call _get_interface_id with parameters: #{hostid.inspect}"

      # 请求后端接口
      result = @client.api_request(
        method: "hostinterface.get",
        params: {
          hostids: hostid
        }
      )
      # 是否为空
      result.empty? ? nil : result[0]["interfaceid"]
    end

    # 批量删除主机
    def mojo_delete(data)
      hostid = get_id(host: data[:host])
      log "[DEBUG] Call get_id with parameters: #{hostid.inspect}"

      result = @client.api_request(
        method: "host.delete",
        params: [hostid]
      )

      # 是否为空
      if result.present?
        p "成功移除监控主机 #{data.ip}"
      else
        p "未能移除监控主机 #{data.ip}"
      end
    end

    # 测试数据
    def update_mojo
      data = {
        name:           "SZX1-16-SW3111111111",
        groups:         [
                          {
                            groupid: 22
                          }
                        ],
        templates:      [
                          {
                            templateid: 10227
                          }
                        ],
        inventory_mode: 1,
        hostid:         15951
      }

      # 请求后端接口
      @client.api_request(method: "host.update", params: data)
    end

    # 根据主机名查询 hostid
    def get_host_id(name)
      result = @client.api_request(
        method: 'host.get',
        params: {
          output: "extend",
          filter: {
            host: name
          }
        }
      )

      # 检查是是否存在
      result.empty? ? nil : result[0]["hostid"]
    end

    # 根据可见名称查询 hostid
    def get_hostid_by_name(name)
      result = @client.api_request(
        method: 'host.get',
        params: {
          output: "extend",
          filter: {
            name: name
          }
        }
      )

      # 检查是是否存在
      result.empty? ? nil : result[0]["hostid"]
    end

    # update host index to serail
    def update_host_to_serial(data)
      # 检索出监控对象的 hostdid
      hostid = get_hostid_by_name(host: data[:name])

      if hostid.present?
        p "已存在监控对象，正在更新 #{data[:name]} 的索引数据 #{data[:host]}"
        # 数据更新期间不处理模板信息 | TODO 后续需要考虑实现
        data.delete(:templates)
        mojo_update("host.update", data.merge(hostid: hostid))
      else
        p "未检索到 #{data[:host]} 监控对象"
      end
    end

    # create_or_update
    def create_or_update(data)
      hostid = get_id(host: data[:host])
      # 此处更新需要拆分为 hosts 和 interfaces 的数据更新
      if hostid.present?
        p "已存在监控对象，正在更新 #{data[:host]} 监控数据"

        # 查询接口对象
        interfaceid = get_interface_id(hostid)
        # 绑定接口属性
        interfaces               = data.delete(:interfaces)
        interfaces[:interfaceid] = interfaceid

        # 数据更新期间不处理模板信息 | TODO 后续需要考虑实现
        data.delete(:templates)

        # 分别更新接口和关联信息
        mojo_update("hostinterface.update", interfaces)
        mojo_update("host.update", data.merge(hostid: hostid))
      else
        p "正在创建 #{data[:host]} 监控对象"
        # 新增监控对象
        create data
      end
    rescue => e
      puts "创建或新增主机 #{data[:host]} 异常，异常信息：#{e}"
      # raise NotImplementedError
    end
  end
end
