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
require 'celluloid/autostart'

# This Gem
Dir[File.dirname(__FILE__) + '/c3d/*.rb'].each            {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/actors/*.rb'].each     {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/bylaws/*.rb'].each     {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/connectors/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/c3d/util/*.rb'].each       {|file| require file }

module C3D
  extend self

  def start
    C3D::SetupC3D.new

    C3D::ConnectTorrent.supervise_as :puller, {
        username: ENV['TORRENT_USER'],
        password: ENV['TORRENT_PASS'],
        url:      ENV['TORRENT_RPC'] }
    C3D::ConnectEth.supervise_as :eth, :cpp

    # todo, need to trap_exit on these actors if they crash
    $puller = Celluloid::Actor[:puller]
    $eth    = Celluloid::Actor[:eth]

    C3D::Utility.save_key
  end

  def stop
    exit 0
  end

  def restart
    C3D.stop
    C3D.start
  end

  def version
    return VERSION
  end
end

if __FILE__==$0
  C3D.start
end