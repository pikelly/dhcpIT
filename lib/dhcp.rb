module DHCP;
  require "dhcp/log"
  require "dhcp/storage"
  require "dhcp/record"
  require "dhcp/server"
  class Error < RuntimeError; end

  def kind
    self.class.to_s.sub("DHCP::","").downcase
  end

end
