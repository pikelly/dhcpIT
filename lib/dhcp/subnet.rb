require "ipaddr"
require 'ping'
require 'dhcp/validations'

module DHCP
  # Represents a DHCP Subnet
  class Subnet
    attr_reader :network, :netmask, :server
    attr_accessor :options

    include DHCP
    include DHCP::Log
    include DHCP::Validations

    def initialize server, network, netmask
      @server  = validate_server server
      @network = validate_ip network
      @netmask = validate_ip netmask
      @options = {}
      @records = {}
      raise DHCP::Error, "unable to Add Subnet" unless @server.add_subnet(self)
    end

    def include? ip
      IPAddr.new(to_s).include?(ip.is_a?(IPAddr) ? ip : IPAddr.new(ip))
    end

    def to_s
      "#{network}/#{netmask}"
    end

    def range
      r=valid_range
      "#{r.first.to_s}-#{r.last.to_s}"
    end

    def clear
      @records = {}
    end

    def loaded?
      size > 0
    end

    def size
      records.count
    end

    def records
      if @records.size == 0
        server.loadSubnetData self
        logger.debug "lazy loaded #{to_s} records"
      end
      @records.values
    end

    def [] record
      @records[record]
    end

    def has_mac? mac
      @records.keys.each {|m| return true if m == mac.downcase }
      return false
    end

    # adds a record to a subnet
    def add_record record
      unless has_mac? record.mac
        @records[record.ip] = record
        logger.debug"Added #{record} to #{to_s}"
        return true
      end
      logger.warn "Record #{record} already exists in #{to_s} - can't add"
      return false
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

    def delete record
      if @records.delete_if{|k,v| v == record}.nil?
        raise DHCP::Error, "Removing a DHCP Record which doesn't exists"
      end
    end

    def valid_range
      # remove broadcast and network address
      IPAddr.new(to_s).to_range.to_a[1..-2]
    end

    def inspect
      self
    end

  end
end
