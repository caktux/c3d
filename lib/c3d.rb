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
Dir[File.dirname(__FILE__) + '/c3d/*.rb'].each {|file| require file }

SetupC3D.new

TransmissionRunner.new.start_transmission
sleep 5

TorrentAPI.supervise_as :puller, {
  username: ENV['TORRENT_USER'],
  password: ENV['TORRENT_PASS'],
  url: ENV['TORRENT_RPC'] }
@swarm_puller = Celluloid::Actor[:puller]

@eth = ConnectEthZMQ.new #:zmq, :cpp
# @ui  = ConnectUI.new
# @ui.async.run

if __FILE__==$0
  blob1 = File.read(ARGV[0]) + "\n#{Time.now}"
  Publish.new @swarm_puller, @eth, blob1, 'a6cb63ec28c12929bee2d3567bf98f374a0b7167', '97d1f086800920e8fd2344be52fb22d7bf6036d2',  '0x2E737671893D33BF53A5F00EDE9E839F9D86E3A391387CA9189CA79729D00000'
end