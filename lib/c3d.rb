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
  create_topc_bylaw = '0x5edc1f1af43c4070bbbfacff737e0e0aaffe240f'
  create_thrd_bylaw = '0x8ea4bea370aacb4404052b6f0fd245bcbe19fcf0'
  create_post_bylaw = '0xe022d281ee266b9abb86220d03bb6e21300bcfe6'
  swarum            = '0x2c9e291d8e2ce5524c4544920fc98d97bdbee824'

  if ARGV[0] == 'first'
    topic             = CreateTopic.new  blob1, create_topc_bylaw, swarum
    topic_id          = topic.topic_id
  end

  if ARGV[0] == 'second'
    topic_id = '0xb36d77fd073e8359ea93c5fd81dab77d898382b6'
  end

  if ARGV[0] == 'first'
    thread            = CreateThread.new blob2, create_thrd_bylaw, topic_id
    thread_id         = thread.thread_id
    thread_blob       = thread.thread_blob
  end

  if ARGV[0] == 'second'
    thread_id = '0xf755208c68f1edf994ba424b6184c9bb57bdeaee'
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

  EyeOfZorax.subscribe swarum
end