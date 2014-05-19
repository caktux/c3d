#!/usr/bin/env ruby

# Ruby std_lib Dependencies
require 'digest/sha1'
require 'json'
require 'yaml'

# Gem Dependencies
require 'httparty'
require 'bencode'
require 'SocketIO'
require 'celluloid/autostart'

# This Gem
require File.join(File.dirname(__FILE__), 'c3d', 'version')
require File.join(File.dirname(__FILE__), 'c3d', 'connect_ethereum_sockets')
require File.join(File.dirname(__FILE__), 'c3d', 'connect_torrent')
# require File.join(File.dirname(__FILE__), 'c3d', 'connect_ui')
require File.join(File.dirname(__FILE__), 'c3d', 'publish')
require File.join(File.dirname(__FILE__), 'c3d', 'subscribe')
require File.join(File.dirname(__FILE__), 'c3d', 'get')

# todo - load these variables from a config file in ~/.epm
SWARM_DIR    = File.join(ENV['HOME'], '.cache', 'c3d')
TORRENTS_DIR = File.join(SWARM_DIR, 'torrents')
BLOBS_DIR    = File.join(SWARM_DIR, 'blobs')
TORRENT_RPC  = "http://127.0.0.1:9091/transmission/rpc"
TORRENT_USER = 'username'
TORRENT_PASS = 'password'
ETHEREUM_RPC = 'http://localhost:8080'
WATCH_FILE   = File.join(SWARM_DIR, 'watchers.json')
IGNORE_FILE  = File.join(SWARM_DIR, 'ignored.json')

# todo - check swarm directories exist
# todo - check that torrent manager is running
# todo - torrentapis use a 'fairly std' rpc framework, but with different
#          endpoints. need to test these though

swarm_puller = TorrentAPI.new(
  username:   TORRENT_USER,
  password:   TORRENT_PASS,
  url:        TORRENT_RPC,
  debug_mode: false
)

blob = File.read(ARGV[0]) + "\n#{Time.now}"
blob = PublishBlob.new blob, swarm_puller

# added = swarm_puller.create("#{t.magnet_link}")

# t = BEncode.load_file('9876.torrent')
# puts t

# torrents = swarm_puller.all
# torrents.each{|t| p 'name'] }

# [{"addedDate"=>1400177739,
#   "files"=>
#    [{"bytesCompleted"=>31752192,
#      "length"=>591396864,
#      "name"=>"ubuntu-14.04-server-amd64.iso"}],
#   "id"=>1,
#   "isFinished"=>false,
#   "name"=>"ubuntu-14.04-server-amd64.iso",
#   "percentDone"=>0.0536,
#   "rateDownload"=>706000,
#   "rateUpload"=>3000,
#   "totalSize"=>591396864}]

# swarm_puller.destroy(1)
# torrent = swarm_puller.find(1)
