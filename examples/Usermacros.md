# Usermacros

This example assumes you have already initialized and connected the ZabbixManager.

For more information and available properties please refer to the Zabbix API documentation for Usermacros:
[https://www.zabbix.com/documentation/4.0/manual/api/reference/usermacro](https://www.zabbix.com/documentation/4.0/manual/api/reference/usermacro)

### User and global macros
```ruby
zbx.usermacros.create(
    :hostid => zbx.hosts.get_id( :host => "Zabbix server" ),
    :macro => "{$ZZZZ}",
    :value => 1.1.1.1
)
```
