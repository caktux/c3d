#!/usr/bin/env ruby

# Ruby std_lib Dependencies
require 'digest/sha1'
require 'json'
require 'yaml'
require 'base64'
require 'net/http'
require 'uri'

# Gem Dependencies
require 'httparty'
require 'bencode'
require 'celluloid/autostart'

# This Gem
Dir[File.dirname(__FILE__) + '/c3d/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/actors/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/bylaws/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/connectors/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/util/*.rb'].each {|file| require file }

SetupC3D.new 'rpc'

ConnectTorrent.supervise_as :puller, {
    username: ENV['TORRENT_USER'],
    password: ENV['TORRENT_PASS'],
    url:      ENV['TORRENT_RPC'] }
$puller = Celluloid::Actor[:puller]

ConnectEth.supervise_as :eth, :cpp
$eth = Celluloid::Actor[:eth]

$ui  = ConnectUI.new @puller, @eth
$ui.async.run

if __FILE__==$0
  blob1             = File.read(ARGV[0]) + "\n#{Time.now}"
  blob2             = File.read(ARGV[0]) + "\n\n#{Time.now}"
  blob3             = File.read(ARGV[0]) + "\n\n\n#{Time.now}"
  create_topc_bylaw = '0x8ea4bea370aacb4404052b6f0fd245bcbe19fcf0'
  create_thrd_bylaw = '0xe022d281ee266b9abb86220d03bb6e21300bcfe6'
  create_post_bylaw = '0x8694b1b125a58704a7d44716dd5f5b0e3055ad2b'
  swarum_top        = '0x6b913721b71e3699488dd1721f89caf73e7399a7'

  topic             = CreateTopic.new  blob1, create_topc_bylaw, swarum_top
  topic_id          = topic.topic_id

  thread            = CreateThread.new blob1, create_thrd_bylaw, topic_id
  thread_id         = thread.thread_id
  thread_blob       = thread.thread_blob

  post              = PostToThread.new blob2, create_post_bylaw, thread_id
  post_id           = post.post_id

  p topic_id
  p thread_id
  p thread_blob
  p post_id
end