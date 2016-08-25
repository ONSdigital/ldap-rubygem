# ONS LDAP RubyGem
Thin wrapper around the [net-ldap](https://rubygems.org/gems/net-ldap) RubyGem. Contains a simple `LDAPConnection` class that can be used to authenticate against an LDAP directory.

## Installation

```
gem install ons-ldap
```

## Example

```ruby
require 'ons-ldap'

host = 'localhost '        # LDAP server host
port = '398'               # LDAP server port
base = 'dc=example,dc=com' # LDAP tree base

# Hash of LDAP group names.
groups = { admins: 'admins', users: 'users' }

ldap_connection = LDAPConnection.new(host, port, base, groups, logger)
user_entry      = ldap_connection.authenticate('johntopley', 'password')

user_entry.user_id      #=> 'johntopley'
user_entry.display_name #=> 'John Topley'
user_entry.token        # 2FA token, stored in LDAP's employeeNumber field for expediency
user_entry.groups       #=> ['admins', 'users']
```

## Testing

```
rake test
```

## Copyright
Copyright (C) 2016 Crown Copyright (Office for National Statistics)
