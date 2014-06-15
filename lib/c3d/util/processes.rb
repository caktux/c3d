#!/usr/bin/env ruby

module C3D
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
      b = `ps ux`.split("\n").select{|e| e[/transmission-daemon -f --no-incomplete-dir -o -C -p /]}
      if ! a.empty? and b.empty?
        p "Please stop your default Transmission Server with `sudo service transmission-daemon stop` and then restart."
        exit 0
      end
      return (! b.empty?)
    end
  end

  module EthRunner
    extend self

    def start_ethereum settings
      unless is_eth_running?
        path = settings["path-to-eth"] || "/opt/cpp-ethereum/build/eth/eth"
        port = settings["eth_rpc_port"] || "9090"
        peer_port = settings["eth_peer_port"] || "30303"
        client_name = settings["eth_client_name"] || "c3d-headless"
        remote = settings["eth_remote"] || ""
        if remote != ""
          remote = "-r #{remote}"
        end
        dir = settings["blockchain_dir"] || ""
        if dir != ""
          dir = "-d #{dir}"
        end
        mine = settings["eth_mine"] || "off"
        if mine == ("off" || "false")
          mine = "-m off"
        elsif mine == ("on" || "true")
          mine = "-m on"
        end
        key = settings["primary_account_key"] || ""
        if key != ""
          key = "-s #{key}"
        end
        pid = spawn "#{path} --json-rpc-port #{port} -l #{peer_port} -c #{client_name} #{remote} #{dir} #{mine} #{key}"
        sleep 7
        at_exit { Process.kill("INT", pid) }
      end
    end


    def is_eth_running?
      a = `ps ux`.split("\n").select{|e| e[/eth --json-rpc-port/]}
      return (! a.empty?)
    end
  end
end