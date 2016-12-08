require 'rubygems'
require 'drb/drb'
require 'nokogiri'
require 'find'
require 'fileutils'
require 'json'
require 'awesome_print'
require 'yaml'

class KexTestCenter
  attr_accessor :kexserver
  def connect(ip)
  # The URI to connect to
    @SERVER_URI="druby://#{ip}:8787"
# Start a local DRbServer to handle callbacks.
#
# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.
    DRb.start_service
    @kexserver = DRbObject.new_with_uri(@SERVER_URI)
    puts @kexserver.get_current_time
    #puts @kexserver.get_thread
  end

  def initial_server_env(dir)
    #change the server active to the right one 
    @kexserver.chdir(dir)
  end

  def run_cmd(commands)
    @kexserver.commands = commands
    @kexserver.run_cmds
  end

  def get_log
     @kexserver.log
  end
   
  def clear_server
     log = Hash.new
     result = Hash.new
     @kexserver.log = log
     @kexserver.result = result
  end
end


host = "localhost" 

host = ARGV[0] if ARGV.count > 0

commands = Array.new
kex = KexTestCenter.new
kex.connect(host)
ARGV.clear
#kex.initial_server_env("E:/projects/P_PlatformSDK/mFact_tools/mfact")
kex.initial_server_env("c:/mfact/mFact_test")
while true
print ">"
cmd = gets.chomp
commands.clear
commands.insert(-1,cmd)
kex.run_cmd(commands)
kex.get_log.each { |l| puts l}
commands.clear
kex.clear_server
end





