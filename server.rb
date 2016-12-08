require 'drb/drb'
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


if ARGV.count > 0
  serverip = ARGV[0]
elsif ! @ip.nil?
  serverip = @ip
else 
  serverip = localhost
end

puts serverip

# The URI for the server to connect to
URI="druby://#{serverip}:8787"

class KexServer
  attr_accessor :commands, :log, :result
  def initialize
     @commands = Array.new
     @log = Hash.new
     @result = Hash.new
     @pwd = Dir.pwd
     puts "initial OK"
  end
  def run_cmds
    ret = 0
    puts "run commands"
    puts @commands
	@commands.each do |command|
	  puts Dir.pwd
	  begin
	    @log[command] = %x(#{command}).to_s
	    @result[command] = $?.exitstatus
	    puts @log[command] if @result[command] != 0
	  rescue
        puts "return #{ret} for #{command}"
	  end
	  ret = ret + 1 if @result[command] != "0"
	end
	return ret
  end

  def get_current_time
    return Time.now
  end

  def get_thread
    return DRb.thread
  end

  def chdir(newdir)
   puts "#{newdir}"
   Dir.chdir(newdir)
   return Dir.pwd
  end

  def resumedir()
    Dir.chdir(@pwd)
    return Dir.pwd
  end

end

# The object that handles requests on the server
FRONT_OBJECT=KexServer.new

#$SAFE = 1   # disable eval() and friends

DRb.start_service(URI, FRONT_OBJECT)
# Wait for the drb server thread to finish before exiting.
DRb.thread.join