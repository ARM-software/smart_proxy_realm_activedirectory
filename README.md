# Foreman Smart Proxy Realm Provider for Active Directory

*A Pure Ruby Active Directory Realm Provider for Foreman's Smart Proxy*

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is tested with Smart Proxy version 1.15.

## Configuration

To enable this Realm provider, edit `/etc/foreman-proxy/settings.d/realm.yml` and set:

    :use_provider: realm_activedirectory

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/realm_activedirectory.yml` and include:

    ---
    # Active Directory settings and authentication
    :realm_name: EXAMPLE.COM
    :realm_server: kdc.example.com
    :realm_basedn: dc=example,dc=com
    # The user principal must have access to create, modify,
    # delete and set passwords on objects defined in :container:
    :realm_principal: svc@EXAMPLE.COM
    :realm_password: secret
    # container OU for where to create all host objects
    :container: ou=computers,dc=example,dc=com
    # alternatively you can specify a container per DNS domain
    #:container:
    #  - domain: ap.example.com
    #    container: ou=computers,dc=ap,dc=example,dc=com
    #  - domain: eu.example.com
    #    container: ou=computers,dc=eu,dc=example,dc=com
    #  - domain: na.example.com
    #    container: ou=computers,dc=na,dc=example,dc=com

Add a snippet to Foreman that takes care of exporting the keytab during provision of hosts. An example snippet using `adcli` can be found in the foreman folder of this project.

## Limitations

Fully qualified hostnames can not exceed 64 characters according to this document:
https://technet.microsoft.com/en-us/library/active-directory-maximum-limits-scalability(v=ws.10).aspx#BKMK_FQDN

The SAMAccountName attribute can not exceed 15 characters and will be truncated:
https://technet.microsoft.com/en-us/library/active-directory-maximum-limits-scalability(v=ws.10).aspx#BKMK_NameLimits

## Active Directory Computer Object Attributes

The following attributes are set in AD when creating example computer `realm-client.example.com`:

Distinguished Name: `CN=realm-client,OU=computers,DC=example,DC=com`

    :objectClass          => ['top', 'person', 'organizationalPerson', 'user', 'computer']
    :userPrincipalName    => 'host/realm-client.example.com@EXAMPLE.COM'
    :servicePrincipalName => 'host/realm-client.example.com'
    :dNSHostName          => 'realm-client.example.com'
    :sAMAccountName       => 'REALM-CLIENT$'
    :pwdLastSet           => 0
    :lockoutTime          => 0
    :unicodePwd           => 'one-time-password'
    :userAccountControl   => 0x1000
    :description          => 'Created by Foreman Smart Proxy'

## Contributing

Fork and send a Pull Request. Thanks!

## TODO

Ideally, the container mapping would not be required if the following changes was made to Foreman:

 - A domain can be associated with a realm
 - It is possible to specify parameters for realms (e.g. domain controller, container)
 - Additional parameters are passed to the realm smart proxy

Other potential improvements:

 - Move from password to credential cache based authentication with AD domain controller
 - Return the Active Directory Object-GUID and store in Foreman for unique reference for all objects created by Foreman

## Copyright

Copyright (c) 2017 Magne Andreassen - Arm Ltd

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
