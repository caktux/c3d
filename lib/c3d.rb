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

$ui  = ConnectUI.new
$ui.async.run

if __FILE__==$0
  test_file         = '../spec/tmp'
  blob1             = File.read(test_file) + "\n#{Time.now}\n#{rand(100000)}"
  blob2             = File.read(test_file) + "\n\n#{Time.now}\n\n#{rand(100000)}"
  blob3             = File.read(test_file) + "\n\n\n#{Time.now}\n\n\n#{rand(100000)}"
  create_topc_bylaw = '0x97f39004ada6817493041bdcbf3e336d83866a28'
  create_thrd_bylaw = '0xbf243f9c059b4f9ee80b86d56facbd41db16bbc1'
  create_post_bylaw = '0x8f132061db2cded96b6d984eb072ca0159c9bd7b'
  swarum_top        = '0xe26d03f0f61f4a68fa415094291d7aa0186abc69'

  if ARGV[0] == 'first'
    topic             = CreateTopic.new  blob1, create_topc_bylaw, swarum_top
    topic_id          = topic.topic_id
  end

  if ARGV[0] == 'second'
    topic_id = '0xBF823AAAE9A87624B3FA1EFD909AE1B9148C99A2'
  end

  if ARGV[0] == 'first'
    thread            = CreateThread.new blob2, create_thrd_bylaw, topic_id
    thread_id         = thread.thread_id
    thread_blob       = thread.thread_blob
  end

  if ARGV[0] == 'second'
    thread_id = '0x9A17422AAF5524F184A00DE597E256A93AD06B61'
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