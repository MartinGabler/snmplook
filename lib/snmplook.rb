require "snmplook/version"


require 'socket'
require 'ipscanner'
require 'snmp'

module Snmplook


      def scan(ip_base = network, range = 1..254, t = 10)
          computers = [] 
          threads = []  
          Socket.do_not_reverse_lookup = false
          (range).map { 
              |i| 
              threads << Thread.new {
                  ip = ip_base + i.to_s
                  if IPScanner.pingecho(ip, t) 
                      computers << Socket.getaddrinfo(ip, nil)[0][3]                    
                  end
              }
          }.join      
          # wait for all threads to terminate
          threads.each { |thread| thread.join }
          return computers
      end

 
  def network_id
    orig = Socket.do_not_reverse_lookup  
    Socket.do_not_reverse_lookup =true # turn off reverse DNS resolution temporarily
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1 #google
      n = s.addr.last.rindex('.')
      s.addr.last[0..n]
    end
    ensure
      Socket.do_not_reverse_lookup = orig
  end

  def request(i, community, snmpversion)
    SNMP::Manager.open(:host => i, :Version => snmpversion, :Community => community) do |manager|
      begin
        response = manager.get([
          ])
        puts "#{i} available"
        i
      rescue SNMP::RequestTimeout 
        puts "#{i} not available"
      end
    end
  end

  def information(f, community, snmpversion)
      output = []

    SNMP::Manager.open(:host => f, :Version => snmpversion, :Community => community) do |manager|

        response = manager.get([ 
          "sysName.0",                  #0 #System Name 
          "sysUpTime.0",                #1 #System Uptime
          "1.3.6.1.4.1.2021.10.1.3.1",  #2 #load average 1min
          "1.3.6.1.4.1.2021.10.1.3.2",  #3 #load average 5min
          "1.3.6.1.4.1.2021.10.1.3.3",  #4 load average 15min
          "1.3.6.1.4.1.2021.4.5.0",     #5 #RAM Total
          "1.3.6.1.4.1.2021.4.6.0",     #6 #RAM used
          "1.3.6.1.4.1.2021.4.14.0",    #7 #RAM buffers
          "1.3.6.1.2.1.2.2.1.10.2",     #8 #NETWORK IN
          "1.3.6.1.2.1.2.2.1.16.2",     #9 #NETWORK OUT
          "1.3.6.1.4.1.2021.11.9.0",    #10 #CPU User 
          "1.3.6.1.4.1.2021.11.10.0",   #11 #CPU System 
          "1.3.6.1.4.1.2021.11.11.0",   #12 #CPU Idle
          "1.3.6.1.4.1.2021.9.1.6.1",   #13 #Disk Total Size (kb)
          "1.3.6.1.4.1.2021.9.1.9.1",   #14 #Disk % Usage
          "sysDescr.0",                 #15 #System Description
          ])
        response.each_varbind do |vb|
          output << "#{vb.value.to_s}"
        end
    end
          ram_used = output[5].to_i - output[6].to_i


          puts "Adress: #{f} Name: #{output[0]} Uptime: #{output[1]}"
          puts "Description: #{output[15]}"
          puts "load average: #{output[2]} #{output[3]} #{output[4]}"
          puts "CPU: #{output[10]}%us, #{output[11]}%sy, #{output[12]}%id"
          puts "Mem: #{output[5]} total, #{ram_used} used, #{output[6]} free, #{output[7]} buffers"
          puts "Network: RX bytes: #{output[8]} TX bytes: #{output[9]}"
          puts "Disk: #{output[13]}kb total, #{output[14]}% used"
          puts ""

  end
end