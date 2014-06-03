#!/usr/bin/env ruby

class TransmissionRunner
  def start_transmission
    unless is_trans_running?
      pid = spawn "transmission-daemon -f --no-incomplete-dir -o -C -p #{ENV['TORRENT_RPC'].split(':').last[0..3]} -w #{ENV['BLOBS_DIR']} -g #{File.join(ENV['HOME'], '.epm')}"
      at_exit { Process.kill("INT", pid) }
    end
  end

  def is_trans_running?
    a = `ps ux`.split("\n").select{|e| e[/transmission-daemon/]}
    return (! a.empty?)
  end
end

class EthZmqRunner
  def start_ethereum_zmq_bridge
    unless is_bridge_running?
      c3d_node = File.join(File.dirname(__FILE__), '..', '..', 'node_modules', 'c3d', 'connect_aleth.js')
      pid = spawn "node #{c3d_node}"
      at_exit { Process.kill("INT", pid) }
    end
  end

  def is_bridge_running?
    a = `ps ux`.split("\n").select{|e| e[/node.*connect_aleth.js$/]}
    return (! a.empty?)
  end
end

class EthRunner
  def start_ethereum
    unless is_eth_running?
      pid = spawn #{todo}""
      at_exit { Process.kill("INT", pid) }
    end
  end

  def is_eth_running?
    a = `ps ux`.split("\n").select{|e| e[/eth/]} #todo cleanup
    return (! a.empty?)
  end
end