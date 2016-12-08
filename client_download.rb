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

threads = []

f = File.read(ARGV[0])
@content = YAML::load(f)

@content.each_key do |ikey|
   threads << Thread.new(ikey) { |key|
    commands = Array.new
    kex = KexTestCenter.new
    kex.connect(@content[key]["ip"])
    kex.initial_server_env(@content[key]["pwd"])
    if @content[key].has_key? "board"
      @content[key]["board"].each_key do |cmd|
        commands.insert(-1, @content[key]["boards"][cmd])
        kex.run_cmd(commands)
        sleep 7200
        commands.clear
        kex.clear_server
      end
    end
    if @content[key].has_key? "chip"
      @content[key]["chip"].each_key do |cmd|
        commands.insert(-1, @content[key]["chip"][cmd])
        kex.run_cmd(commands)
        sleep 7200
        commands.clear
        kex.clear_server
      end
    end
  }
end
threads.each { |aThread|  aThread.join }



