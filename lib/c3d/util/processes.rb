#!/usr/bin/env ruby

module TransmissionRunner
  extend self
  def start_transmission
    unless is_trans_running?
      pid = spawn "transmission-daemon -f --no-incomplete-dir -o -C -p #{ENV['TORRENT_RPC'].split(':').last[0..3]} -w #{ENV['BLOBS_DIR']} -g #{File.join(ENV['HOME'], '.epm')}"
      sleep 3
      at_exit { Process.kill("INT", pid) }
    end
  end

  def is_trans_running?
    a = `ps ux`.split("\n").select{|e| e[/transmission-daemon/]}
    return (! a.empty?)
  end
end

module EthRunner
  extend self

  def start_ethereum
    unless is_eth_running?
      pid = spawn #{todo}
      at_exit { Process.kill("INT", pid) }
    end
  end

  def is_eth_running?
    a = `ps ux`.split("\n").select{|e| e[/eth/]} #todo cleanup
    return (! a.empty?)
  end
end