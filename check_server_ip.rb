require 'socket'
require 'ipaddr'

@ip = "127.0.0.1"

def my_valid_public_ipv4
  Socket.ip_address_list.each do |intf| 
    if intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast?
      puts "detected ip #{intf.ip_address}"
      @ip = intf.ip_address if intf.ip_address.include? "10."
    end
  end
end

my_valid_public_ipv4

puts @ip

STDIN.getc
