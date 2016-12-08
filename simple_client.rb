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
    puts @kexserver.get_thread
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



commands = Array.new
kex = KexTestCenter.new
kex.connect("localhost")
kex.initial_server_env("E:/projects/P_PlatformSDK/mFact_tools/mfact")
commands.insert(-1, "ruby ./mfact_watir.rb ./pk/nortos/sdk_2_0/test/windows/all/FRDM-KL02Z.yml all chrome sdk_2_0")
kex.run_cmd(commands)
kex.get_log.each do |key, value|
  puts "command is : #{key}"
  puts "result is"
  puts value
end
commands.clear
kex.clear_server
=begin
kex.connect("10.193.99.61")
#kex.connect("10.192.244.7")
#kex.initial_server_env("c:/mfact/mFact_test")
kex.initial_server_env("E:/projects/P_PlatformSDK/mFact_tools/mfact")
#commands.insert(-1, "ruby ./mfact_watir.rb pk/nortos/sdk_2_0/stage/windows/all/FRDM-K22F.yml all chrome sdk_2_0")
commands.insert(-1, "./test.bat pk/sdk_2_0/stage/linux/all/ all")
kex.run_cmd(commands)
ap kex.get_log
commands.clear
kex.clear_server
=end




