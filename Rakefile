#!/usr/bin/env rake
require 'rake/testtask'
require_relative 'lib/ons-ldap/version'

task default: :test

desc 'Build the gem'
task build: [:test] do
  system('gem build ons-ldap.gemspec')
end

desc 'Push the gem to the Gem In A Box server'
task release: [:build] do
  system("gem inabox ons-ldap-#{ONSLDAP::VERSION}.gem")
end

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end
