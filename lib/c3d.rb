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
Dir[File.dirname(__FILE__) + '/c3d/*.rb'].each            {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/actors/*.rb'].each     {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/bylaws/*.rb'].each     {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/connectors/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/util/*.rb'].each       {|file| require file }

if __FILE__==$0
  SetupC3D.new

  ConnectTorrent.supervise_as :puller, {
      username: ENV['TORRENT_USER'],
      password: ENV['TORRENT_PASS'],
      url:      ENV['TORRENT_RPC'] }
  ConnectEth.supervise_as :eth, :cpp

  # todo, need to trap_exit on these actors if they crash
  $puller = Celluloid::Actor[:puller]
  $eth    = Celluloid::Actor[:eth]

  Utility.save_key

  $ui = ConnectUI.new
  $ui.async.run

  test_file         = '../spec/fixtures/tmp'
  blob1             = File.read(test_file) + "\n#{Time.now}\n#{rand(100000)}"
  blob2             = File.read(test_file) + "\n\n#{Time.now}\n\n#{rand(100000)}"
  blob3             = File.read(test_file) + "\n\n\n#{Time.now}\n\n\n#{rand(100000)}"
  doug              = '0xb1081dfef79f48ebe0bdfa9a93cea70df7330a88'
  create_topc_bylaw = $eth.get_storage_at doug, '0x424C5743546F7069630000000000000000000000000000000000000000000000'
  create_thrd_bylaw = $eth.get_storage_at doug, '0x424C574354687265616400000000000000000000000000000000000000000000'
  create_post_bylaw = $eth.get_storage_at doug, '0x424C57506F737454540000000000000000000000000000000000000000000000'
  swarum            = $eth.get_storage_at doug, '0x73776172756D0000000000000000000000000000000000000000000000000000'
  blacklist         = $eth.get_storage_at doug, '0x626C61636B6C6973740000000000000000000000000000000000000000000000'

  if ARGV[0] == 'first'
    topic    = CreateTopic.new  blob1, create_topc_bylaw, swarum
    topic_id = topic.topic_id
  end

  if ARGV[0] == 'second'
    topic_id = $eth.get_storage_at swarum, '0x19'
  end

  if ARGV[0] == 'first'
    thread      = CreateThread.new blob2, create_thrd_bylaw, topic_id
    thread_id   = thread.thread_id
    thread_blob = thread.thread_blob
  end

  if ARGV[0] == 'second'
    thread_id = $eth.get_storage_at topic_id, '0x19'
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
    TreeBuilder.new [doug], [], true
  end

  EyeOfZorax.subscribe doug
end