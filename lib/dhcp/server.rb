require "dhcp/subnet"
require "dhcp/record"

module DHCP
  # represents a DHCP Server
  class Server
    @@subnets = []
    attr_reader :name
    alias_method :to_s, :name

    include DHCP
    include DHCP::Log
    include DHCP::Validations

    # The library will probably be accessed via this class method from foreman
    # Foreman does not want to know much about servers
    def self.[] subnet
      @@subnets.find{ |s| s.include? subnet }
    end

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
        @subnets  << validate_subnet(subnet)
        @@subnets << subnet unless @@subnets.map(&:network).include?(subnet.network)
        logger.debug "added #{subnet} to #{name}"
        return true
      end
      logger.warn "subnet #{subnet} already exists in server #{name}"
      return false
    end

    def find_subnet value
      @subnets.find{ |s| s.include? value }
    end

    def find_record record
      if subnet = find_subnet(record)
        return subnet[record]
      end
    end

    def inspect
      self
    end

    def delRecord subnet, record
      subnet.delete_record record
    end

  end
end
