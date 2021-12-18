class ZabbixManager
  class Basic
    # Initializes a new Basic object with ZabbixManager Client
    #
    # @param client [ZabbixManager::Client]
    # @return [ZabbixManager::Client]
    def initialize(client)
      @client = client
    end

    # Placeholder for inherited objects to provide object-specific method name
    #
    # @raise [ManagerError] Basic object does not directly support method_name
    def method_name
      raise ManagerError.new("Can't call method_name here")
    end

    # Placeholder for inherited objects to provide default options
    #
    # @return [Hash]
    def default_options
      {}
    end

    # Returns the object's plural id field name (identify) based on key
    #
    # @return [String]
    def keys
      key + 's'
    end

    # Returns the object's id field name (identify) based on method_name + id
    #
    # @return [String]
    def key
      method_name + 'id'
    end

    # Placeholder for inherited objects to provide object-specific id field name
    #
    # @raise [ManagerError] Basic object does not directly support identify
    def identify
      raise ManagerError.new("Can't call identify here")
    end
  end
end
