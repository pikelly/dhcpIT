require "ipaddr"
require 'ping'
require 'dhcp/validations'

module DHCP
  # Represents a DHCP Subnet
  class Subnet < Hash
    attr_reader :network, :netmask, :server
    attr_accessor :options, :loaded

    include DHCP
    include DHCP::Log
    include DHCP::Validations

    def initialize server, network, netmask
      @server  = validate_server server
      @network = validate_ip network
      @netmask = validate_ip netmask
      @options = {}
      @loaded  = false
      raise DHCP::Error, "unable to Add Subnet" unless @server.add_subnet(self)
      super()
    end

    def include? value
      ip = IPAddr.new(value) if value.is_a? String
      ip = value.ip          if value.is_a? DHCP::Record
      ip ||= value
      IPAddr.new(to_s).include?( ip )
    end

    def to_s
      "#{network}/#{netmask}"
    end

    def range
      r=valid_range
      "#{r.first.to_s}-#{r.last.to_s}"
    end

    def loaded?
      # It is quite possible that a subnet contains no leases so size == 0 will not do.
      @loaded
    end

    def [] value
      ip = value.ip          if value.is_a? DHCP::Record
      ip = value.to_s        if value.is_a? IPAddr
      ip ||= value
      server.loadSubnetData(self) unless loaded?
      super ip
    end

    def records
      server.loadSubnetData(self) unless loaded?
      values
    end

    def has_mac? mac
      values.detect {|record| record.mac == mac.downcase }
    end

    # adds a record to a subnet
    def []= ip, record
      if has_mac? record.mac
        logger.warn "Record #{record} already exists in #{to_s} - can't add"
        return false
      end
      super
    end

    def add_record record
      self[record.ip] = record
    end

    # returns the next unused IP Address in a subnet
    # Pings the IP address as well (just in case its not in DHCP)
    def unused_ip
      ips = valid_range.collect(&:to_s)
      used = records.collect(&:ip)
      free_ips = ips - used
      if free_ips.empty?
        logger.warn "No free IPs at #{to_s}"
        return nil
      else
        free_ips.each do |ip|
          logger.debug "searching for free ip - pinging #{ip}"
          if Ping.pingecho(ip)
            logger.info "found a pingable IP(#{ip}) address which don't have a DHCP record"
          else
            logger.debug "found free ip #{ip} out of a total of #{free_ips.size} free ips"
            return ip
          end
        end
      end
    end

    def delete_record record
      raise DHCP::Error, "Removing a DHCP Record which doesn't exists" unless delete record.ip
    end

    def valid_range
      # remove broadcast and network address
      IPAddr.new(to_s).to_range.to_a[1..-2]
    end

    #def inspect
    #  self
    #end

  end
end
