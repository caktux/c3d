#!/usr/bin/env ruby

# Ruby std_lib Dependencies
require 'digest/sha1'
require 'json'
require 'yaml'
require 'base64'

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
require File.join(File.dirname(__FILE__), 'c3d', 'util')
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
  # if ARGV[0]
    blob1 = File.read(ARGV[0]) + "\n#{Time.now}"
    PublishBlob.new blob1, '38155ef3698a43b24b054d816a8a5f79fc148623', '71e08d9f82414efd9023a4040eec8f927ff32fd8',  '0x73FAC42E61AD7BDC6A77E31157996748DE86E9AD6FCC0C18C8720DCFBA100000'
    blob2 = 'as;dlfkajfbdposdituy2q-034956712840918734uytgqklerjdnga,.fxsnvbmaz x.,c'
    PublishBlob.new blob2, '38155ef3698a43b24b054d816a8a5f79fc148623', '71e08d9f82414efd9023a4040eec8f927ff32fd8',  '0x73FAC42E61AD7BDC6A77E31157996748DE86E9AD6FCC0C18C8720DCFBA100000'
    # Utility.add_group_to_ethereum '0xa6cb63ec28c12929bee2d3567bf98f374a0b7167', '4320838ed6aff9ad8df45e261780af69e7c599ba', 'ThISisIt', @@eth
    PublishBlob.new blob2, nil
  # end
end