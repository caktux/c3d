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

SetupC3D.new

ConnectTorrent.supervise_as :puller, {
    username: ENV['TORRENT_USER'],
    password: ENV['TORRENT_PASS'],
    url:      ENV['TORRENT_RPC'] }
$puller = Celluloid::Actor[:puller]

ConnectEth.supervise_as :eth, :cpp
$eth = Celluloid::Actor[:eth]

Utility.save_key

$ui  = ConnectUI.new
$ui.async.run

if __FILE__==$0
  test_file         = '../spec/tmp'
  blob1             = File.read(test_file) + "\n#{Time.now}\n#{rand(100000)}"
  blob2             = File.read(test_file) + "\n\n#{Time.now}\n\n#{rand(100000)}"
  blob3             = File.read(test_file) + "\n\n\n#{Time.now}\n\n\n#{rand(100000)}"
  create_topc_bylaw = '0xac87f593b892e9c25bfe5c8e085ecf80bb9b7a70'
  create_thrd_bylaw = '0xcc58b5745edec3574025f35c30ffc44fe843637e'
  create_post_bylaw = '0xf1c290bd72d37e14d3bc7efc6eee6143ac54e37a'
  swarum_top        = '0xd28218256cdfc6f5b369e3e549a3f528ba8ff322'

  if ARGV[0] == 'first'
    topic             = CreateTopic.new  blob1, create_topc_bylaw, swarum_top
    topic_id          = topic.topic_id
  end

  if ARGV[0] == 'second'
    topic_id = '0x69d3a3c7f1818475a064e419a5267be42c6d98b6'
  end

  if ARGV[0] == 'first'
    thread            = CreateThread.new blob2, create_thrd_bylaw, topic_id
    thread_id         = thread.thread_id
    thread_blob       = thread.thread_blob
  end

  if ARGV[0] == 'second'
    thread_id = '0x6dbe4c8f2fe525cc93d22f732f695c52f1f0a77a'
  end

  if ARGV[0] == 'first'
    post              = PostToThread.new blob3, create_post_bylaw, thread_id
    post_id           = post.post_id
  end

  if ARGV[0] == 'second'
    25.times do
      blob3             = File.read(test_file) + "\n\n\n#{Time.now}\n\n\n#{rand(100000)}"
      post              = PostToThread.new blob3, create_post_bylaw, thread_id
      post_id           = post.post_id
    end
  end

  if ARGV[0] == 'third'
    Subscribe.new
  end

  EyeOfZorax.subscribe swarum_top
end