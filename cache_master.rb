#!/usr/bin/env ruby
require 'digest/sha1'
require './transmission_connector'
require './make_blob_torrent'

SWARM_DIR    = File.join(ENV['HOME'], '.cache', 'etherswarm')
TORRENTS_DIR = File.join(SWARM_DIR, 'torrents')
BLOBS_DIR    = File.join(SWARM_DIR, 'blobs')

# todo - check directory exists

swarm_puller = TransmissionApi.new(
  :username => "username",
  :password => "password",
  :url      => "http://127.0.0.1:9091/transmission/rpc",
  :debug_mode => false
)

blob      = File.read(ARGV[0]) + "\n#{Time.now}"
sha1_full = Digest::SHA1.hexdigest blob
sha1_trun = sha1_full[0..23]
tor_file  = File.join(TORRENTS_DIR, "#{sha1_trun}.torrent")
blob_file = File.join(BLOBS_DIR, sha1_trun)
File.open(blob_file, 'w'){|f| f.write(blob)}

t = Torrent.new blob_file
t.write_torrent tor_file

torrent  = swarm_puller.create tor_file
btih     = torrent['hashString']
mag_link = "magnet:?xt=urn:btih:" + btih + "&dn=" + sha1_trun
puts "[OWIG3::#{Time.now.strftime( "%F %T" )}] Magnet Link >> " + mag_link

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
