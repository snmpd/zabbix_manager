class ZabbixManager
  class Problems < Basic
    # The method name used for interacting with Hosts via Zabbix API
    #
    # @return [String]
    def method_name
      'problem'
    end

    # The id field name used for identifying specific Problem objects via Zabbix API
    #
    # @return [String]
    def identify
      'name'
    end

    # The key field name used for Problem objects via Zabbix API
    # However, Problem object does not have a unique identifier
    #
    # @return [String]
    def key
      'problemid'
    end

    # Returns the object's plural id field name (identify) based on key
    # However, Problem object does not have a unique identifier
    #
    # @return [String]
    def keys
      'problemids'
    end

    # Dump Problem object data by key from Zabbix API
    #
    # @param data [Hash] Should include desired object's key and value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def dump_by_id(data)
      log "[DEBUG] Call dump_by_id with parameters: #{data.inspect}"

      @client.api_request(
        method: 'problem.get',
        params: {
          filter: {
            identify.to_sym => data[identify.to_sym]
          },
          output: 'extend'
        }
      )
    end

    # Get full/extended Problem data from Zabbix API
    #
    # @param data [Hash] Should include object's id field name (identify) and id value
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Hash]
    def get_full_data(data)
      log "[DEBUG] Call get_full_data with parameters: #{data.inspect}"

      data = symbolize_keys(data)

      @client.api_request(
        method: "#{method_name}.get",
        params: {
          filter:                {
            identify.to_sym => data[identify.to_sym]
          },
          eventids:              data[:eventids] || nil,
          groupids:              data[:groupids] || nil,
          hostids:               data[:hostids] || nil,
          objectids:             data[:objectids] || nil,
          applicationids:        data[:applicationids] || nil,
          tags:                  data[:tags] || nil,
          time_from:             data[:time_from] || nil,
          time_till:             data[:time_till] || nil,
          eventid_from:          data[:eventid_from] || nil,
          eventid_till:          data[:eventid_till] || nil,
          recent:                data[:recent] || false,
          sortfield:             data[:sortfield] || ['eventid'],
          sortorder:             data[:sortorder] || 'DESC',
          countOutput:           data[:countOutput] || nil,
          output:                'extend',
          selectAcknowledges:    'extend',
          selectTags:            'extend',
          selectSuppressionData: 'extend'
        }
      )
    end

    # Get full/extended Zabbix data for Problem objects from API
    #
    # @raise [ManagerError] Error returned when there is a problem with the Zabbix API call.
    # @raise [HttpError] Error raised when HTTP status from Zabbix Server response is not a 200 OK.
    # @return [Array<Hash>] Array of matching objects
    def all
      get_full_data({})
    end

    def remove_problem
      # 设置时间区间
      time_from = 180.days.ago.at_beginning_of_day.to_i
      time_till = 14.days.ago.at_beginning_of_day.to_i

      # 抓取制定区间的数据
      data      = get_full_data(time_from: time_from, time_till: time_till)
      event_ids = []

      # 收集所有的 eventid
      data.each do |item|
        event_ids << item["eventid"]
      end

      # 返回 event_ids
      ack_event event_ids
    end

    def ack_event(eventids)
      # 请求后端
      result = @client.api_request(
        method: "event.acknowledge",
        params: {
          eventids: eventids,
          action:   2,
          message:  "由 RUBY SCRIPT 自动关闭"
        }
      )
      # 返回运行结果
      result
    end
  end
end