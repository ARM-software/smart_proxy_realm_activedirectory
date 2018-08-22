require 'net/ldap'
require 'securerandom'
require 'digest/sha1'

module Proxy::Realm::ActiveDirectory
  class LdapWrapper
    include Proxy::Log
    include Proxy::Util

    ACCOUNTDISABLE = 0x0002
    WORKSTATION_TRUST_ACCOUNT = 0x1000

    attr_reader :ldap, :sammy

    def initialize(server, basedn, principal, password, sammy)
      @sammy = sammy
      @ldap  = Net::LDAP.new(
        :host       => server,
        :base       => basedn,
        :port       => 636,
        :encryption => :simple_tls,
        :auth       => {
          :method     => :simple,
          :username   => principal,
          :password   => password
        }
      )
      raise "Error #{@ldap.get_operation_result.message}" unless @ldap.bind
    rescue Net::LDAP::LdapError => e
      raise e
    end

    def find_host_dn(fqdn)
      result = @ldap.search(:filter => spn_filter(fqdn))
      check_ldap_result('search-host')
      result.empty? ? nil : result.first.dn
    end

    def create_host(dn, fqdn, setattr = {})
      raise 'Hostname exceeds 64 character limit' if fqdn.size > 64
      setattr.merge!(samaccount(fqdn)) unless @sammy.eql?('passive')
      setattr.merge!(
        :objectClass          => %w[top person organizationalPerson user computer],
        :dNSHostName          => fqdn,
        :servicePrincipalName => ["host/#{fqdn}"],
        :userAccountControl   => (ACCOUNTDISABLE + WORKSTATION_TRUST_ACCOUNT).to_s,
        :description          => 'Created by Foreman Smart Proxy'
      )
      @ldap.add(:dn => dn, :attributes => setattr)
      check_ldap_result('create-host')
      change_password(dn)
    end

    def change_password(dn)
      password = SecureRandom.hex(24)
      @ldap.modify(
        :dn => dn,
        :operations => [
          [:replace, :pwdLastSet,         ['0']],
          [:replace, :lockoutTime,        ['0']],
          [:replace, :unicodePwd,         [encode_password(password)]],
          [:replace, :userAccountControl, [WORKSTATION_TRUST_ACCOUNT.to_s]]
        ]
      )
      check_ldap_result('change-host-password')
      { 'randompassword' => password }
    end

    def destroy_host(dn)
      @ldap.delete(:dn => dn)
      check_ldap_result('delete-host')
    end

    private

    def check_ldap_result(operation)
      code = @ldap.get_operation_result.code
      text = @ldap.get_operation_result.message
      logger.debug("LDAP operation '#{operation}' result: #{code} #{text}")
      raise "LDAP error: #{code} #{text}" unless code.zero?
    end

    # http://msdn.microsoft.com/en-us/library/cc223248.aspx
    # https://groups.google.com/forum/#!topic/rubyonrails-talk/ey5hAhXBB10
    def encode_password(password)
      quotepwd = "\"#{password}\""
      unicodepwd = quotepwd.chars.map { |c| "#{c}\000" }
      unicodepwd.join
    end

    def spn_filter(fqdn)
      base_filter = Net::LDAP::Filter.eq(:objectClass, 'computer')
      host_filter = Net::LDAP::Filter.eq(:servicePrincipalName, "host/#{fqdn}")
      Net::LDAP::Filter.join(base_filter, host_filter)
    end

    def samaccount(fqdn)
      case @sammy
      when 'legacy'
        olsam = fqdn.split('.').shift
        olsam = olsam.slice(0..14) if olsam.size > 15
        { :sAMAccountName => olsam.upcase + '$' }
      when 'md5-digest'
        olsam = Digest::MD5.hexdigest(fqdn).slice(0..14)
        { :sAMAccountName => olsam.upcase + '$' }
      else
        logger.error "Unsupported setting :samaccountname: #{@sammy}"
        {}
      end
    end
  end
end
