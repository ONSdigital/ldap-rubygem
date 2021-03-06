require 'net/ldap'

UserEntry = Struct.new(:user_id, :display_name, :token, :groups)

class LDAPConnection

  # Class instance variables.
  class << self
    attr_accessor :host
    attr_accessor :port
    attr_accessor :base
    attr_accessor :groups
    attr_accessor :logger
  end

  def initialize(host, port, base, groups, logger)
    self.class.host = host
    self.class.port = port.to_i
    self.class.base = base
    self.class.groups = groups
    self.class.logger = logger
  end

  def authenticate(username, password)
    user_entry = nil

    # Have to use the username DN format below for the bind operation to succeed.
    auth = { method: :simple, username: "uid=#{username},ou=Users,#{self.class.base}", password: password }

    Net::LDAP.open(host: self.class.host, port: self.class.port, encryption: :simple_tls, base: self.class.base, auth: auth) do |ldap|
      unless ldap.bind
        result = ldap.get_operation_result
        self.class.logger.error "LDAP authentication failed for '#{username}': #{result.message} (#{result.code})"
        return nil
      end

      self.class.logger.info "LDAP authentication succeeded for '#{username}'"
      user_entry = entry_for(username, ldap) || nil

      # The user must be a member of at least the "<zone>-users" group for authentication to be considered successful.
      users_group = self.class.groups['users']
      unless group_member?(users_group, username, ldap)
        self.class.logger.error "LDAP authentication failed: '#{username}' is not a member of the '#{users_group}' group"
        return nil
      end

      user_entry.groups = groups_for(username, ldap)
    end

    user_entry
  end

  private

  # Returns the LDAP directory entry for a user.
  def entry_for(username, ldap)
    filter     = Net::LDAP::Filter.construct("uid=#{username}")
    attributes = %w(uid displayName employeeNumber) # employeeNumber is used to store the 2FA token.
    user_entry = nil

    succeeded = ldap.search(filter: filter, attributes: attributes, return_result: false) do |entry|
      user_entry = UserEntry.new(entry.uid.first, entry.displayName.first, entry.employeeNumber.first)
    end

    unless succeeded
      result = ldap.get_operation_result
      self.class.logger.error "Error searching the LDAP directory using filter '#{filter}': #{result.message} (#{result.code})"
    end

    user_entry
  end

  # Returns the LDAP groups a user belongs to.
  def groups_for(username, ldap)
    filter     = Net::LDAP::Filter.construct("(&(objectClass=posixGroup)(memberUid=#{username}))")
    attributes = %w(cn)
    groups     = []
    succeeded = ldap.search(filter: filter, attributes: attributes, return_result: false) do |entry|
      groups << entry[:cn].first
    end
    unless succeeded
      result = ldap.get_operation_result
      self.class.logger.error "Error searching the LDAP directory using filter '#{filter}': #{result.message} (#{result.code})"
    end
    groups
  end

  # Returns whether a user is a member of a group.
  def group_member?(group, username, ldap)
    self.class.logger.info "group: '#{group}'"
    filter     = Net::LDAP::Filter.construct("(&(cn=#{group})(memberUid=#{username}))")
    attributes = %w(cn)
    group_cn   = nil

    succeeded = ldap.search(filter: filter, attributes: attributes, return_result: false) do |entry|
      group_cn = entry.cn.first
    end

    unless succeeded
      result = ldap.get_operation_result
      self.class.logger.error "Error searching the LDAP directory using filter '#{filter}': #{result.message} (#{result.code})"
    end

    group_cn == group
  end
end
