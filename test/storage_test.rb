require 'test/test_helper'

class DHCPStorageTest < Test::Unit::TestCase

  def setup
#    @storage = DHCP::Storage::InMemory.new
    @storage = $storage

    @server = DHCP::Server.new("testcase")
    @subnet = DHCP::Subnet.new(@server,"192.168.0.0","255.255.255.0")
    @record = DHCP::Record.new(@subnet, "123.321.123.321", "aa:bb:CC:dd:ee:ff")
  end

  def test_should_store_server
    @storage.add @server
    assert @storage.include? @server
  end

  def test_should_store_subnet
    @storage.add @subnet
    assert @storage.include? @subnet
  end

  def test_should_store_record
    @storage.add @record
    assert @storage.include? @record
  end

 def test_should_find_subnet
    @storage.add @subnet
    s = @storage.find_subnet("192.168.0.0/255.255.255.0")
    assert_equal @subnet,s
  end

  def test_should_find_record
    @storage.add @record
    assert_equal @record, @storage.find_record("aa:bb:cC:dd:ee:ff")
  end

  def test_should_find_server
    @storage.add @server
    assert_equal @server, @storage.find_server("testcase")
  end




end
