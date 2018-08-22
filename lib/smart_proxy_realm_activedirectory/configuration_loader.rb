module Proxy::Realm::ActiveDirectory
  class ConfigurationLoader
    def load_classes
      require 'smart_proxy_realm_activedirectory/realm_activedirectory_provider'
      require 'smart_proxy_realm_activedirectory/realm_activedirectory_ldapwrapper'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.dependency :realm_ldap_obj, lambda {
        Proxy::Realm::ActiveDirectory::LdapWrapper.new(
          settings[:realm_server],
          settings[:realm_basedn],
          settings[:realm_principal],
          settings[:realm_password],
          settings[:samaccountname]
        )
      }
      container_instance.dependency :realm_provider_impl, lambda {
        Proxy::Realm::ActiveDirectory::Provider.new(
          container_instance.get_dependency(:realm_ldap_obj),
          settings[:realm_name],
          settings[:container]
        )
      }
    end
  end
end
