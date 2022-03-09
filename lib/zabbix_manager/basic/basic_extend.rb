# frozen_string_literal: true

class ZabbixManager
  class Basic
    # 新增 get_hostgroup_ids 方法，使用列表 flatten 功能拉平属组对象
    def get_hostgroup_ids(data)
      result = @client.api_request(
        method: "hostgroup.get",
        params: {
          output: "extend",
          filter: {
            name: [data].flatten
          }
        }
      ).map { |item| { groupid: item["groupid"] } }

      # 检查是是否存在
      result.empty? ? nil : result.flatten
    end

    # 新增 get_or_create_hostgroups 方法，查询或创建新的对象
    def get_or_create_hostgroups(data)
      [data].flatten.each do |item|
        # 是否存在设备属组，不存在则新建

        result = get_hostgroup_ids(item)
        if result.nil?
          @client.api_request(
            method: "hostgroup.create",
            params: {
              name: item
            }
          )
        end
      rescue StandardError => e
        ap e
      end
    end
  end
end
