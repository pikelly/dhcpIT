require "dhcp/subnet"
require "dhcp/validations"

module DHCP
  # represent a DHCP Record
  class Record

    attr_reader :ip, :mac, :title, :subnet
    attr_accessor :options
    include DHCP
    include DHCP::Log
    include DHCP::Validations

    def initialize(subnet, ip, mac, options = {})
      @subnet = validate_subnet subnet
      @ip = validate_ip ip
      @mac = validate_mac mac.downcase
      @options = options
      raise DHCP::Error, "unable to Add Record" unless @subnet.add_record(self)
    end

    def to_s
      "#{ip} / #{mac}"
    end

  end
end
