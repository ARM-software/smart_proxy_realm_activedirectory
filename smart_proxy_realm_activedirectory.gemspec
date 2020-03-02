require File.expand_path('../lib/smart_proxy_realm_activedirectory/realm_activedirectory_version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_realm_activedirectory'
  s.version     = Proxy::Realm::ActiveDirectory::VERSION
  s.date        = '2018-08-22'
  s.license     = 'GPL-3.0'
  s.authors     = ['Magne Andreassen']
  s.email       = ['magne.andreassen@arm.com']
  s.homepage    = 'https://github.com/ARM-software/smart_proxy_realm_activedirectory'

  s.summary     = "Active Directory Realm Provider Plugin for Foreman's Smart Proxy"
  s.description = "A Pure Ruby Active Directory Realm Provider Plugin for Foreman's Smart Proxy"

  s.files       = Dir['{foreman,puppet,settings.d,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_dependency('net-ldap', '~> 0.16.1')

  s.add_development_dependency('mocha', '~> 1')
  s.add_development_dependency('rake', '>= 12.3.3')
  s.add_development_dependency('test-unit', '~> 2')
end
