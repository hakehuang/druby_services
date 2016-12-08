require 'rubygems'
require 'drb/drb'
require 'nokogiri'
require 'find'
require 'fileutils'
require 'json'
require "awesome_print"
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

def getIPbyname(name)
  begin
    Socket::getaddrinfo(name, nil, nil, Socket::SOCK_STREAM)[0][3]
  rescue Exception => e
    return nil
  end
end


threads = []

f = File.read(ARGV[0])
@content = YAML::load(f)

@content.each_key do |key|
    commands = Array.new
    kex = KexTestCenter.new
    puts key
    @ip = getIPbyname(key)
    puts @ip
    #if @ip.nil?
    @ip = @content[key]['ip']
    puts @ip
    #end
    begin
    kex.connect(@ip)
    puts @content[key]["pwd"]
    kex.initial_server_env(@content[key]["pwd"])
    commands = Array.new
    commands.insert(-1, "git pull")
    kex.run_cmd(commands)
    puts "#{@content[key]["ip"]} is OK"
    rescue Exception => e  
  puts e.message  
  puts e.backtrace.inspect  
    puts "check #{@content[key]["ip"]} name #{key} fails"
    end
end





