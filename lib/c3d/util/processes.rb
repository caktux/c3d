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

  def start_ethereum settings
    unless is_eth_running?
      path = settings["path-to-eth"] || "/opt/cpp-ethereum/build/eth/eth"
      port = settings["eth_rpc_port"] || "9090"
      remote = settings["eth_remote"] || "54.201.28.117"
      dir = settings["blockchain_dir"] || "~/.ethereum"
      peer_port = settings["eth_peer_port"] || "30303"
      client_name = settings["eth_client_name"] || "c3d-headless"
      key = settings["primary_account_key"] || ""
      pid = spawn "#{path} --json-rpc-port #{port} -r #{remote} -d #{dir} -m off -l #{peer_port} -c #{client_name} -s #{key}"
      sleep 7
      at_exit { Process.kill("INT", pid) }
    end
  end


  def is_eth_running?
    a = `ps ux`.split("\n").select{|e| e[/eth --json-rpc-port/]}
    return (! a.empty?)
  end
end