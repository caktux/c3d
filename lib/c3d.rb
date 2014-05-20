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
# todo - trap transmission not running errors

@@swarm_puller = TorrentAPI.new(
  username:   TORRENT_USER,
  password:   TORRENT_PASS,
  url:        TORRENT_RPC,
  debug_mode: false
)
@@eth = ConnectEth.new
@@ui  = ConnectUI.new
@@ui.async.run

if __FILE__==$0
  if ARGV[0]
    blob1 = File.read(ARGV[0]) + "\n#{Time.now}"
    PublishBlob.new blob1, 'a6cb63ec28c12929bee2d3567bf98f374a0b7167', 'd00383d79aaede0ed34fab69e932a878e00a8938',  '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600000'
    blob2 = 'as;dlfkajfbdposdituy2q-034956712840918734uytgqklerjdnga,.fxsnvbmaz x.,c'
    PublishBlob.new blob2, 'a6cb63ec28c12929bee2d3567bf98f374a0b7167', 'd00383d79aaede0ed34fab69e932a878e00a8938',  '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600000'
    # PublishBlob.new blob2, nil
  end
end