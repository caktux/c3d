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

  if ARGV[0] == 'third'
    TreeBuilder.new [doug], [], true
  end

  EyeOfZorax.subscribe doug
end