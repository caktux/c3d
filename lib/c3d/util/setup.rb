#!/usr/bin/env ruby

module C3D
  class SetupC3D
    include Celluloid

    def initialize
      set_deps
      config = get_config
      set_the_env config
      set_trans_config config
      set_c3d_config config
      start_processes config
    end

    private

    def set_deps
      dep_exist? 'transmission-daemon', 'sudo apt-get install transmission-daemon && sudo service transmission-daemon stop && sudo update-rc.d -f transmission-daemon remove'
    end

    def get_config
      dir_exist? File.join(ENV['HOME'], '.epm')
      config_file  = File.join(ENV['HOME'], '.epm', 'c3d-config.json')
      config_example = File.join(File.dirname(__FILE__), '..', '..', '..', 'settings', 'c3d-config.json')
      unless File.exists? config_file
        tmp = File.read config_example
        until ! tmp[/(\{\{USERHOME\}\})/]
          tmp.gsub!("{{USERHOME}}", ENV["HOME"])
          p 'hello'
        end
        print "Before we begin, I need to ask you two personal questions:\n"
        print "What is your primary account which I should be using to send transactions?\n\n"
        account = STDIN.gets.chomp
        print "Thanks. #{account} is what I will use.\n"
        print "Thanks. Now what is the private key for that account which I should be using?\n\n"
        secret = STDIN.gets.chomp
        print "Thanks. #{secret} is what I will use.\n"
        account = "0x#{account}" if account[0..1] != '0x'
        secret = "0x#{secret}" if secret[0..1] != '0x'
        tmp.gsub!("{{0xACCT}}", account)
        tmp.gsub!("{{0xSEC}}", secret)
        File.open(config_file, 'w'){|f| f.write(tmp)}
      end
      return JSON.load(File.read(config_file))
    end

    def set_the_env config
      ENV['SWARM_DIR']     = config['swarm_dir']
      ENV['TORRENTS_DIR']  = config['torrents_dir']
      ENV['BLOBS_DIR']     = config['blobs_dir']
      ENV['WATCH_FILE']    = config['watch_file']
      ENV['IGNORE_FILE']   = config['ignore_file']
      ENV['TORRENT_RPC']   = config['torrent_rpc']
      ENV['TORRENT_USER']  = config['torrent_user']
      ENV['TORRENT_PASS']  = config['torrent_pass']
      ENV['UI_RESPOND']    = config['ui_respond']
      ENV['UI_ANNOUNCE']   = config['ui_announce']
      ENV['ETH_CONNECTOR'] = config['eth_connector']
      ENV['ETH_ZMQ_ADDR']  = config['eth_zmq_addr']
      ENV['ETH_HOST']      = config['eth_rpc_host']
      ENV['ETH_PORT']      = config['eth_rpc_port']
      ENV['ETH_KEY']       = config['primary_account_key']
    end

    def set_trans_config config
      trans_file = File.join(ENV['HOME'], '.epm', 'settings.json')
      trans_example = File.join(File.dirname(__FILE__), '..', '..', '..', 'settings', 'transmission.json')
      unless File.exists? trans_file
        FileUtils.cp trans_example, trans_file
      end
      trans_config = JSON.load(File.read(trans_file))
      trans_config["incomplete-dir"]        = config['download_dir']
      trans_config["download-queue-size"]   = config['download-queue-size'].to_i
      trans_config["queue-stalled-minutes"] = config['queue-stalled-minutes'].to_i
      trans_config["seed-queue-size"]       = config['seed-queue-size'].to_i
      File.open(trans_file, 'w'){|f| f.write(JSON.pretty_generate(trans_config))}
    end

    def set_c3d_config config
      dir_exist?  ENV['SWARM_DIR']
      dir_exist?  ENV['TORRENTS_DIR']
      dir_exist?  ENV['BLOBS_DIR']
      dir_exist?  config['download_dir']
      file_exist? ENV['WATCH_FILE']
      file_exist? ENV['IGNORE_FILE']
    end

    def start_processes config
      C3D::TransmissionRunner.start_transmission
      C3D::EthRunner.start_ethereum config
    end

    def dir_exist? directry
      unless File.directory? directry
        Dir.mkdir directry
      end
    end

    def file_exist? fil
      unless File.exists? fil
        File.open(fil, "w") {}
      end
    end

    def dep_exist? dependency, fixer
      unless which dependency
        `#{fixer}`
      end
    end

    def which cmd
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        }
      end
      return nil
    end
  end
end