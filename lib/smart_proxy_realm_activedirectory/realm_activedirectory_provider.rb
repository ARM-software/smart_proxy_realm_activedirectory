module Proxy::Realm::ActiveDirectory
  class Provider
    include Proxy::Log
    include Proxy::Util

    attr_reader :wrapper, :realm, :container

    def initialize(wrapper, realm, container)
      @wrapper   = wrapper
      @realm     = realm
      @container = container
    end

    def find(fqdn)
      @wrapper.find_host_dn(fqdn)
    end

    def create(realm, fqdn, params)
      check_realm(realm)
      hostdn = find(fqdn)
      setattr = { :userPrincipalName => "host/#{fqdn}@#{realm}" }
      if hostdn.nil?
        newdn = create_host_dn(fqdn)
        logger.info "Creating new host: #{newdn}"
        result = @wrapper.create_host(newdn, fqdn, setattr)
      elsif params[:rebuild] == 'true'
        logger.info "Changing password on host: #{hostdn}"
        result = @wrapper.change_password(hostdn)
      else
        logger.info "Host exist but won't modify #{hostdn}"
        result = { 'message' => 'nothing to do' }
      end
      JSON.pretty_generate(result)
    end

    def delete(realm, fqdn)
      check_realm(realm)
      hostdn = @wrapper.find_host_dn(fqdn)
      logger.info "Deleting host: #{hostdn}"
      @wrapper.destroy_host(hostdn)
    end

    private

    def check_realm(realm)
      raise "Unknown realm #{realm}" unless realm.casecmp(@realm).zero?
    end

    def create_host_dn(fqdn)
      domain = fqdn.split('.').drop(1).join('.')
      hostname = fqdn.split('.').shift
      container = get_container(domain)
      raise 'Empty hostname error' if hostname.empty?
      "cn=#{hostname},#{container}"
    end

    def get_container(domain)
      case @container
      when Hash
        raise "No container for #{domain}" unless @container.key?(domain)
        @container[domain]
      when String
        raise 'Undefined container' if @container.empty?
        @container
      else
        raise 'Error in container, expecting Hash or String'
      end
    end
  end
end
