# frozen_string_literal: true

require "zabbix_manager/version"
require "zabbix_manager/client"

require "zabbix_manager/basic/basic_alias"
require "zabbix_manager/basic/basic_func"
require "zabbix_manager/basic/basic_init"
require "zabbix_manager/basic/basic_logic"

require "zabbix_manager/classes/actions"
require "zabbix_manager/classes/applications"
require "zabbix_manager/classes/configurations"
require "zabbix_manager/classes/errors"
require "zabbix_manager/classes/events"
require "zabbix_manager/classes/graphs"
require "zabbix_manager/classes/hostgroups"
require "zabbix_manager/classes/hosts"
require "zabbix_manager/classes/httptests"
require "zabbix_manager/classes/items"
require "zabbix_manager/classes/maintenance"
require "zabbix_manager/classes/mediatypes"
require "zabbix_manager/classes/proxies"
require "zabbix_manager/classes/problems"
require "zabbix_manager/classes/roles"
require "zabbix_manager/classes/screens"
require "zabbix_manager/classes/scripts"
require "zabbix_manager/classes/server"
require "zabbix_manager/classes/templates"
require "zabbix_manager/classes/triggers"
require "zabbix_manager/classes/unusable"
require "zabbix_manager/classes/usergroups"
require "zabbix_manager/classes/usermacros"
require "zabbix_manager/classes/users"
require "zabbix_manager/classes/valuemaps"
require "zabbix_manager/classes/drules"

class ZabbixManager
  # @return [ZabbixManager::Client]
  attr_reader :client

  # Initializes a new ZabbixManager object
  #
  # @param options [Hash]
  # @return [ZabbixManager]
  def self.connect(options = {})
    new(options)
  end

  # @return [ZabbixManager]
  def self.current
    @current ||= ZabbixManager.new
  end

  # Executes an API request directly using a custom query
  #
  # @param data [Hash]
  # @return [Hash]
  def query(data)
    @client.manager_request(method: data[:method], params: data[:params])
  end

  # Invalidate current authentication token
  # @return [Boolean]
  def logout
    @client.logout
  end

  # Initializes a new ZabbixManager object
  #
  # @param options [Hash]
  # @return [ZabbixManager::Client]
  def initialize(options = {})
    @client = Client.new(options)
  end

  # @return [ZabbixManager::Actions]
  def actions
    @actions ||= Actions.new(@client)
  end

  # @return [ZabbixManager::Applications]
  def applications
    @applications ||= Applications.new(@client)
  end

  # @return [ZabbixManager::Configurations]
  def configurations
    @configurations ||= Configurations.new(@client)
  end

  # @return [ZabbixManager::Events]
  def events
    @events ||= Events.new(@client)
  end

  # @return [ZabbixManager::Graphs]
  def graphs
    @graphs ||= Graphs.new(@client)
  end

  # @return [ZabbixManager::HostGroups]
  def hostgroups
    @hostgroups ||= HostGroups.new(@client)
  end

  # @return [ZabbixManager::Hosts]
  def hosts
    @hosts ||= Hosts.new(@client)
  end

  # @return [ZabbixManager::HttpTests]
  def httptests
    @httptests ||= HttpTests.new(@client)
  end

  # @return [ZabbixManager::Items]
  def items
    @items ||= Items.new(@client)
  end

  # @return [ZabbixManager::Maintenance]
  def maintenance
    @maintenance ||= Maintenance.new(@client)
  end

  # @return [ZabbixManager::Mediatypes]
  def mediatypes
    @mediatypes ||= Mediatypes.new(@client)
  end

  # @return [ZabbixManager::Problems]
  def problems
    @problems ||= Problems.new(@client)
  end

  # @return [ZabbixManager::Proxies]
  def proxies
    @proxies ||= Proxies.new(@client)
  end

  # @return [ZabbixManager::Roles]
  def roles
    @roles ||= Roles.new(@client)
  end

  # @return [ZabbixManager::Screens]
  def screens
    @screens ||= Screens.new(@client)
  end

  # @return [ZabbixManager::Scripts]
  def scripts
    @scripts ||= Scripts.new(@client)
  end

  # @return [ZabbixManager::Server]
  def server
    @server ||= Server.new(@client)
  end

  # @return [ZabbixManager::Templates]
  def templates
    @templates ||= Templates.new(@client)
  end

  # @return [ZabbixManager::Triggers]
  def triggers
    @triggers ||= Triggers.new(@client)
  end

  # @return [ZabbixManager::Usergroups]
  def usergroups
    @usergroups ||= Usergroups.new(@client)
  end

  # @return [ZabbixManager::Usermacros]
  def usermacros
    @usermacros ||= Usermacros.new(@client)
  end

  # @return [ZabbixManager::Users]
  def users
    @users ||= Users.new(@client)
  end

  # @return [ZabbixManager::ValueMaps]
  def valuemaps
    @valuemaps ||= ValueMaps.new(@client)
  end

  # @return [ZabbixManager::Drules]
  def drules
    @drules ||= Drules.new(@client)
  end
end
