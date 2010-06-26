$: << "../foreman/vendor/rails/activesupport/lib/"
$: << "../foreman/vendor/rails/activesupport/lib/active_support/vendor/memcache-client-1.7.4"
$: << "../foreman/vendor/rails/activesupport/lib/active_support/vendor/builder-2.1.2"
require "active_support/core_ext"
require "active_support/cache"

require 'test/test_helper'

class DHCPServerTest < Test::Unit::TestCase

  def setup
    @server = DHCP::Server.new("testcase")
    @subnet = DHCP::Subnet.new(@server, "192.168.0.0", "255.255.255.0")
    @record = DHCP::Record.new(@subnet, "192.168.0.11", "aa:bb:cc:dd:ee:ff")
  end

  def test_should_provide_subnets
    assert_respond_to @server, :subnets
  end

  def test_should_add_subnet
    counter = @server.subnets.count
    DHCP::Subnet.new(@server, "192.168.1.0", "255.255.255.0")
    assert_equal counter+1, @server.subnets.count
  end

  def test_should_not_add_duplicate_subnets
    assert_raise DHCP::Error do
      DHCP::Subnet.new(@server, "192.168.0.0", "255.255.255.0")
    end
  end

  def test_should_find_subnet_based_on_network
    assert_equal @subnet, @server.find_subnet("192.168.0.0")
  end

  def test_should_find_subnet_based_on_dhcp_record
    assert_equal @subnet, @server.find_subnet(@record)
  end

  def test_should_find_subnet_based_on_ipaddr
    ip = IPAddr.new "192.168.0.11"
    assert_equal @subnet, @server.find_subnet(ip)
  end

  def test_should_find_record_based_on_ip
    assert_equal @record, @server.find_record("192.168.0.11")
  end

  def test_should_find_record_based_on_dhcp_record
    assert_equal @record, @server.find_record(@record)
  end

  def test_should_find_record_based_on_ipaddr
    ip = IPAddr.new "192.168.0.11"
    assert_equal @record, @server.find_record(ip)
  end

  def test_should_return_nil_when_no_subnet
    subnet = @server.find_subnet IPAddr.new "1.20.76.0"
    assert_nil subnet
  end

  def test_should_have_a_name
    assert !@server.name.nil?
  end

  def test_should_find_global_subnet
    @server2 = DHCP::Server.new("testcase2")
    @subnet2 = DHCP::Subnet.new(@server, "192.168.1.0", "255.255.255.0")

    net1 = DHCP::Server["192.168.1.0"]
    net2 = DHCP::Server["192.168.0.0"]
    assert_kind_of DHCP::Subnet, net1
    assert_kind_of DHCP::Subnet, net2
    assert net1 != net2
  end

  def test_should_support_caching
    cache = ActiveSupport::Cache::MemCacheStore.new "localhost"
    cache.clear
    cache.write("servers", @server)
    @recovered = cache.fetch("servers")
    assert_equal @subnet["192.168.0.11"].mac, @recovered.find_subnet("192.168.0.0")["192.168.0.11"].mac
  end
end
