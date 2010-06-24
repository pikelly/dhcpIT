require "dhcp/subnet"
require "dhcp/record"

module DHCP
  # represents a DHCP Server
  class Server
    attr_reader :name
    alias_method :to_s, :name

    include DHCP
    include DHCP::Log
    include DHCP::Validations

    def initialize(name)
      @name = name
      @subnets = []
      @@debug = false
    end

    def subnets
      loadSubnets if @subnets.size == 0
      return @subnets
    end

    # Abstracted Subnet loader method
    def loadSubnets
      logger.debug "loading subnets for #{name}"
    end

    # Abstracted Subnet data loader method
    def loadSubnetData subnet
      logger.debug "loading subnets for #{subnet}"
    end

    # Abstracted Subnet options loader method
    def loadSubnetOptions subnet
      logger.debug "loading Subnet options for #{subnet}"
    end

    # Adds a Subnet to a server object
    def add_subnet subnet
      logger.debug "adding subnet #{subnet} to #{name}"
      if find_subnet(subnet.network).nil?
        @subnets << validate_subnet(subnet)
        logger.debug "added #{subnet} to #{name}"
        return true
      end
      logger.warn "subnet #{subnet} already exists in server #{name}"
      return false
    end

    def find_subnet value
      @subnets.each do |s|
        return s if value.is_a?(String) and s.network == value
        return s if value.is_a?(DHCP::Record) and s.include?(value.ip)
        return s if value.is_a?(IPAddr) and s.include?(value)
      end
      return nil
    end

    def find_record record
      @subnets.each do |s|
        s.records.each do |v|
          return v if record.is_a?(String) and v.ip == record
          return v if record.is_a?(DHCP::Record) and v == record
          return v if record.is_a?(IPAddr) and v.ip == record.to_s
        end
      end
      return nil
    end

    def inspect
      self
    end


    def delRecord subnet, record
      subnet.delete record
    end

  end
end
