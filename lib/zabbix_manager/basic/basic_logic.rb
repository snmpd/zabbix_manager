# frozen_string_literal: true

class ZabbixManager
  class Basic
    # Create new Zabbix object using API (with defaults)
    #
    # @param data [Hash]
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] The object id if a single object is created
    # @return [Boolean] True/False if multiple objects are created
    def create(data)
      log "[DEBUG] Call create with parameters: #{data.inspect}"

      # 判断是否绑定默认选项并重新生成配置
      data_with_default = default_options.empty? ? data : merge_params(default_options, data)
      data_create       = [data_with_default]

      # 调用实例方法
      result = @client.api_request(method: "#{method_name}.create", params: data_create)
      # 判断是否执行成功并返回结果
      parse_keys result
    end

    # Delete Zabbix object using API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] The object id if a single object is deleted
    # @return [Boolean] True/False if multiple objects are deleted
    def delete(data)
      log "[DEBUG] Call delete with parameters: #{data.inspect}"

      data_delete = [data]
      result      = @client.api_request(method: "#{method_name}.delete", params: data_delete)
      parse_keys result
    end

    # Create or update Zabbix object using API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] The object id if a single object is created
    # @return [Boolean] True/False if multiple objects are created
    def create_or_update(data)
      log "[DEBUG] Call create_or_update with parameters: #{data.inspect}"

      id = get_id(identify.to_sym => data[identify.to_sym])
      id ? update(data.merge(key.to_sym => id.to_s)) : create(data)
    end

    # Update Zabbix object using API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @param force [Boolean] Whether to force an object update even if provided data matches Zabbix
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] The object id if a single object is created
    # @return [Boolean] True/False if multiple objects are created
    def update(data, force = false)
      log "[DEBUG] Call update with parameters: #{data.inspect}"
      dump = {}
      dump_by_id(key.to_sym => data[key.to_sym]).each do |item|
        dump = symbolize_keys(item) if item[key].to_i == data[key.to_sym].to_i
      end
      if hash_equals?(dump, data) && !force
        log "[DEBUG] Equal keys #{dump} and #{data}, skip update"
        data[key.to_sym].to_i
      else
        data_update = [data]
        result      = @client.api_request(method: "#{method_name}.update", params: data_update)
        parse_keys result
      end
    end

    # mojo_update 请求补丁函数
    def mojo_update(method, data)
      log "[DEBUG] Call update with parameters: #{data.inspect}"
      @client.api_request(method: method, params: data)
    end

    # MOJO_UPDATE

    # Get full/extended Zabbix object data from API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def get_full_data(data)
      log "[DEBUG] Call get_full_data with parameters: #{data.inspect}"

      @client.api_request(
        method: "#{method_name}.get",
        params: {
          filter: {
            identify.to_sym => data[identify.to_sym]
          },
          output: "extend"
        }
      )
    end

    # Get raw Zabbix object data from API
    #
    # @param data [Hash]
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def get_raw(data)
      log "[DEBUG] Call get_raw with parameters: #{data.inspect}"

      @client.api_request(
        method: "#{method_name}.get",
        params: data
      )
    end

    # Dump Zabbix object data by key from API
    #
    # @param data [Hash] Should include desired object's key and value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def dump_by_id(data)
      log "[DEBUG] Call dump_by_id with parameters: #{data.inspect}"

      @client.api_request(
        method: "#{method_name}.get",
        params: {
          filter: {
            key.to_sym => data[key.to_sym]
          },
          output: "extend"
        }
      )
    end

    # Get full/extended Zabbix data for all objects of type/class from API
    #
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Array<Hash>] Array of matching objects
    def all
      result = {}
      @client.api_request(
        method: "#{method_name}.get",
        params: { output: "extend" }
      ).each do |item|
        result[item[identify]] = item[key]
      end
      result
    end

    # Get Zabbix object id from API based on provided data
    #
    # @param data [Hash]
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call or missing object's id field name (identify).
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Zabbix object id
    def get_id(data)
      log "[DEBUG] Call get_id with parameters: #{data.inspect}"

      # symbolize keys if the user used string keys instead of symbols
      data = symbolize_keys(data) if data.key?(identify)
      # raise an error if identify name was not supplied
      name = data[identify.to_sym]
      raise ManagerError, "#{identify} not supplied in call to get_id" if name.nil?

      result = @client.api_request(
        method: "#{method_name}.get",
        params: {
          filter: data,
          output: [key, identify]
        }
      )
      id = nil
      result.each { |item| id = item[key].to_i if item[identify] == data[identify.to_sym] }
      id
    end

    # Get or Create Zabbix object using API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Integer] Zabbix object id
    def get_or_create(data)
      log "[DEBUG] Call get_or_create with parameters: #{data.inspect}"

      unless (id = get_id(identify.to_sym => data[identify.to_sym]))
        id = create(data)
      end
      id
    end

    # 根据数据自动创建
    def create_raw(data)
      log "[DEBUG] Call create_raw with parameters: #{data.inspect}"
      # 请求创建数据
      @client.api_request(
        method: "#{method_name}.create",
        params: data
      )
    end

    # 根据数据自动更新数据
    def update_raw(data)
      log "[DEBUG] Call update_raw with parameters: #{data.inspect}"
      # 请求创建数据
      @client.api_request(
        method: "#{method_name}.update",
        params: data
      )
    end

    # 根据数据自动删除数据
    def delete_raw(data)
      log "[DEBUG] Call delete_raw with parameters: #{data.inspect}"
      # 请求创建数据
      @client.api_request(
        method: "#{method_name}.delete",
        params: data
      )
    end
  end
end
