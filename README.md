# Ruby Zabbix Api Module

[![Gem Version](http://img.shields.io/gem/v/zabbix_manager.svg)][gem]

[gem]: https://rubygems.org/gems/zabbix_manager

Most codes borrowed from zabbixapi, but fit for my everyday works well!
Simple and lightweight ruby module for working with [Zabbix][Zabbix] via the [Zabbix API][Zabbix API]

## Installation
```sh
# latest
gem install zabbix_manager

# specific version
gem install zabbix_manager -v 4.2.0
```

## Documentation
[http://rdoc.info/gems/zabbix_manager][documentation]

[documentation]: http://rdoc.info/gems/zabbix_manager

## Examples


## Supported Ruby Versions
This library aims to support and is [tested against][github-ci] the following Ruby
versions:

* Ruby 2.5
* Ruby 2.6
* Ruby 2.7
* JRuby 9.2.10.0

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer. Being a maintainer
entails making sure all tests run and pass on that implementation. When
something breaks on your implementation, you will be responsible for providing
patches in a timely fashion. If critical issues for a particular implementation
exist at the time of a major release, support for that Ruby version may be
dropped.

## Dependencies

* net/http
* json

## Contributing

* Fork the project.
* Base your work on the master branch.
* Make your feature addition or bug fix, write tests, write documentation/examples.
* Commit, do not mess with rakefile, version.
* Make a pull request.

## Zabbix documentation

* [Zabbix Project Homepage][Zabbix]
* [Zabbix API docs][Zabbix API]

[Zabbix]: https://www.zabbix.com
[Zabbix API]: https://www.zabbix.com/documentation/5.2/manual/api
