require 'test/test_helper'

class DHCPSubnetTest < Test::Unit::TestCase

  def setup
    @network = "192.168.0.0"
    @netmask = "255.255.255.0"
    @server = DHCP::Server.new("testcase")
    @subnet = DHCP::Subnet.new @server, @network, @netmask
  end

  def test_subnet_should_have_a_server
    assert_kind_of DHCP::Server, @subnet.server
  end

  def test_should_convert_to_string
    assert_equal @subnet.to_s, "#{@network}/#{@netmask}"
  end

  def test_should_have_a_logger
    assert_respond_to @subnet, :logger
  end

  def test_should_not_save_invalid_network_addresses
    network = "1..1.1"
    assert_raise DHCP::Validations::Error do
      DHCP::Subnet.new(@server, network, @netmask)
    end
  end

  def test_should_not_save_invalid_netmask
    netmask = "XYZxxVVcc123"
    assert_raise DHCP::Validations::Error do
      DHCP::Subnet.new(@server, @network, netmask)
    end
  end

  def test_should_not_save_invalid_server
    server = nil
    assert_raise DHCP::Validations::Error do
      DHCP::Subnet.new(server, @network, @netmask)
    end
  end

  def test_options_should_be_a_hash
    assert_kind_of Hash, @subnet.options
  end

  def test_subnet_includes_ip
    assert @subnet.include? "192.168.0.10"
  end

  def test_subnet_does_not_include_ip
    assert @subnet.include?("192.168.5.10") == false
  end

  def test_should_provide_range_excluding_network_address
   assert @subnet.valid_range.include?("192.168.0.0") == false
  end

  def test_should_provide_range_excluding_broadcast_address
   assert @subnet.valid_range.include?("192.168.0.255") == false
  end

  def test_range
    assert_equal @subnet.range, "192.168.0.1-192.168.0.254"
  end

  def add_record
    ip = "192.168.0.50"
    mac = "aa:bb:cc:dd:ee:Ff"
    @subnet.add_record DHCP::Record.new(@subnet, ip, mac)
  end

  def test_should_add_records
    counter = @subnet.size
    add_record
    assert_equal @subnet.size, counter+1
  end

  def test_should_not_import_the_same_record_twice
    add_record
    counter = @subnet.size
    add_record
    assert_equal @subnet.size, counter
  end

  def test_should_clear_records
    add_record
    @subnet.clear
    assert_equal @subnet.size, 0
  end

  def test_subnet_records_should_point_back_to_subnet
    add_record
    @subnet.records.each do |record|
      assert_equal @subnet, record.subnet
    end
  end

  def test_it_should_be_possible_to_find_subnet_record_based_on_ip
    add_record
    assert_kind_of DHCP::Record, @subnet["192.168.0.50"]
  end

  def test_should_remove_records
    add_record
    counter = @subnet.size
    @server.delRecord @subnet, @subnet["192.168.0.50"]
    assert_equal @subnet.size, counter-1
  end

end
