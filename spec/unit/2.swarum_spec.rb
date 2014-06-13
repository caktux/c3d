#!/usr/bin/env ruby
require 'spec_helper'

def get_set_up
  SetupC3D.new
  ConnectTorrent.supervise_as :puller, {
      username: ENV['TORRENT_USER'],
      password: ENV['TORRENT_PASS'],
      url:      ENV['TORRENT_RPC'] }
  ConnectEth.supervise_as :eth, :cpp
  $puller           = Celluloid::Actor[:puller]
  $eth              = Celluloid::Actor[:eth]
end

def get_latest_doug
  log = File.join(ENV['HOME'], '.epm', 'deployed-log.csv')
  if File.exists? log
    log = File.read log
  else
    unless ARGV[0]
      raise
    end
    return ARGV[0]
  end
  # find the last doug
  return log.split("\n").map{|l| l.split(',')}.select{|l| l[0] == ("Doug" || "DOUG" || "doug")}[-1][-1]
end

def get_dougs_storage position
  unless position[0..1] == '0x'
    position = EPM::HexData.construct_data [position]
  end
  return $eth.get_storage_at @doug, position
end

def make_test_file
  test_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'tmp')
  return File.read(test_file) + "\n#{Time.now}\n#{rand(100000)}"
end

describe "Publishing Content from c3D to Ethereum" do

  before(:context) do
    get_set_up
    @doug   = get_latest_doug
    @swarum = get_dougs_storage 'swarum'
    @topic  = CreateTopic.new  make_test_file, get_dougs_storage('BLWCTopic'),  @swarum
    @thread = CreateThread.new make_test_file, get_dougs_storage('BLWCThread'), @topic.topic_id
    @post   = PostToThread.new make_test_file, get_dougs_storage('BLWPostTT'),  @thread.thread_id
  end

  # check number of files in blobs dir before and after
  # check files were added to torrent
  # use blob_id to do the above

  it "should publish topics to the blockchain." do
    expect( @topic.topic_id ).to be
  end

  it "should publish threads to the blockchain." do
    expect( @thread.thread_id ).to be
  end

  it "should publish a post to the previously made thread." do
    expect( @post.post_id ).to be
  end

  # @thread_blob = @thread.thread_blob
  # @post_blob = @post.post_blob
end