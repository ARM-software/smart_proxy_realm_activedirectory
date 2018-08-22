module Proxy::Realm::ActiveDirectory
  class Plugin < Proxy::Provider
    default_settings :samaccountname => 'legacy'

    plugin :realm_activedirectory, ::Proxy::Realm::ActiveDirectory::VERSION

    load_classes ::Proxy::Realm::ActiveDirectory::ConfigurationLoader
    load_dependency_injection_wirings ::Proxy::Realm::ActiveDirectory::ConfigurationLoader

    validate_presence :realm_name, :realm_server, :realm_basedn,
                      :realm_principal, :realm_password,
                      :container, :samaccountname
  end
end
