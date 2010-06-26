# dhcpIT

DHCP Servers API written in ruby

# currently supports
* ISC DHCP
* MS DHCP Server


# known limitations
* ISC record manipulations are only possible for dynamic hosts (e.g. created via this interface or omshell)

* MS DHCP Server requires a CGI like script running on an IIS server

# Usage

<pre><code>
#!/usr/bin/env ruby

require 'dhcp'
require 'dhcp/server/isc'

config = "/etc/dhcp3/dhcpd.conf"
leases = "/var/lib/dhcp3/dhcpd.leases"
server = "127.0.0.1"

server=DHCP::ISC.new(server, config, leases)
server.subnets # array of Subnets

subnet = server.find_subnet "192.168.0.0"
subnet.records # array or records

record = subnet["192.168.0.1"] # record 

subnet.unused_ip # next free ip address in subnet which is not pingable

server.delRecord(subnet, record) # deletes 192.168.0.1 dhcp record

server.addRecord({ :mac=>"54:52:00:4b:a5:18", :nextserver=>"192.168.0.5",
  :hostname=>"dummy.lan", :filename=>"pxelinux.0",
  :name=>"dummy.lan", :ip=>"192.168.0.146"})

</code></pre>

Work in progress :-) see tests for more code examples


Licence
-------

GPLv3 - copyright ohad.levy@infineon.com 2010
