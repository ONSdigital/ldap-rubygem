require_relative 'lib/ons-ldap/version'

Gem::Specification.new do |s|
  s.name        =  'ons-ldap'
  s.version     =  ONSLDAP::VERSION
  s.date        =  Date.today.to_s
  s.summary     =  'LDAP connection class'
  s.description =  'Simple class for authenticating against an LDAP directory.'
  s.authors     =  ['John Topley','Philip Sharland']
  s.email       =  ['john.topley@ons.gov.uk','philip.sharland@ons.gov.uk']
  s.files       =  ['README.md']
  s.files       += Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/ONSdigital/ldap-rubygem'
  s.license     = 'Crown Copyright (Office for National Statistics)'

  s.add_runtime_dependency 'net-ldap', '~>0', '>= 0.11'
end
