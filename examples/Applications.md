# Applications

This example assumes you have already initialized and connected the ZabbixManager.

For more information and available properties please refer to the Zabbix API documentation for Applications:
[https://www.zabbix.com/documentation/4.0/manual/api/reference/application](https://www.zabbix.com/documentation/4.0/manual/api/reference/application)

## Create Application
```ruby
zbx.applications.create(
  :name => application,
  :hostid => zbx.templates.get_id(:host => "template")
)
```
