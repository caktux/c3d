#!/usr/bin/env ruby

# Ruby std_lib Dependencies
require 'digest/sha1'
require 'json'
require 'yaml'

# Gem Dependencies
require 'httparty'
require 'bencode'
require 'celluloid/autostart'

# This Gem
require File.join(File.dirname(__FILE__), 'c3d', 'version')
require File.join(File.dirname(__FILE__), 'c3d', 'connect_ethereum')
require File.join(File.dirname(__FILE__), 'c3d', 'connect_torrent')
require File.join(File.dirname(__FILE__), 'c3d', 'connect_ui')
require File.join(File.dirname(__FILE__), 'c3d', 'publish')
require File.join(File.dirname(__FILE__), 'c3d', 'subscribe')
require File.join(File.dirname(__FILE__), 'c3d', 'get')

# todo - load these variables from a config file in ~/.epm
SWARM_DIR    = File.join(ENV['HOME'], '.cache', 'c3d')
TORRENTS_DIR = File.join(SWARM_DIR, 'torrents')
BLOBS_DIR    = File.join(SWARM_DIR, 'blobs')
TORRENT_RPC  = 'http://127.0.0.1:9091/transmission/rpc'
TORRENT_USER = 'username'
TORRENT_PASS = 'password'
ETH_ADDRESS  = 'tcp://127.0.0.1:31315'
UI_ADDRESS   = 'tcp://127.0.0.1:31314'
WATCH_FILE   = File.join(SWARM_DIR, 'watchers.json')
IGNORE_FILE  = File.join(SWARM_DIR, 'ignored.json')

# todo - check that torrent manager is running
# todo - torrentapis use a 'fairly std' rpc framework, but with different
#          endpoints. need to test these though
# todo - check dependencies are installed: zmq ... transmission
# todo - add foreman

@@swarm_puller = TorrentAPI.new(
  username:   TORRENT_USER,
  password:   TORRENT_PASS,
  url:        TORRENT_RPC,
  debug_mode: true
)
@@eth = ConnectEth.new

if __FILE__==$0
  if ARGV[0]
    blob1 = File.read(ARGV[0]) + "\n#{Time.now}"
    PublishBlob.new blob1, false, false, false
    blob2 = 'as;dlfkajfbdposdituy2q-034956712840918734uytgqklerjdnga,.fxsnvbmaz x.,c'
    PublishBlob.new blob2, false, false, false
  end
end