#!/usr/bin/env ruby

require 'json'
require 'celluloid/autostart'
require 'base64'

class Subscribe
  include Celluloid
  attr_accessor :tor_file, :blob_file, :sha1_trun

  def initialize puller, eth
    @eth = eth
    @puller = puller
    assemble_queries
  end

  def assemble_queries
    # watched, ignored = load_library
    # watched[contract] = [group1,group2] || watched[contract]=[] <=all
    watched = {"97d1f086800920e8fd2344be52fb22d7bf6036d2" => []}
    watched.each_key do |contract|
      # todo - build
      latest_group = send_query contract, '0x18'
      latest_group_author = send_query contract, latest_group
      step = iterate latest_group
      prev_group = send_query contract, step      # prev_group == '0x16' => first_group
      step = iterate step
      next_group = send_query contract, step      # next_group == '0x' => last_group
      step = iterate step
      title1 = send_query contract, step
      step = iterate step
      title2 = send_query contract, step
      title = eth_strings title1
      title << eth_strings(title2) unless title2 == '0x'
      step = iterate step
      posts_in_group = (send_query contract, step).to_i(16)
      step = iterate step
      latest_blob = send_query contract, step
      p latest_group
      p latest_group_author
      p next_group
      p prev_group
      p title
      p posts_in_group
      p latest_blob
      next_blob = ''
      until next_blob == '0x'
        next_blob          = send_query contract, latest_blob
        latest_blob_author = send_query contract, latest_blob.next
        blob_id            = send_query contract, latest_blob.next.next
        p next_blob
        p latest_blob_author
        get_the_blob blob_id unless do_i_have_it? blob_id
        latest_blob = next_blob
      end
    end
    #read watcher file && build hash
    #read igored file && delete from hash
    #for each watched contract
      # for each watched group
        #first subquery is to group_id + 5 - contains the number of blobs -> compare to stored val in the JSON
        #if that number is has not changed, check group_id + 6 - contains the newest post -> compare to stored val in the JSON
          #if that number is the same, do nothing
          #if that number has changed, check blob_id + 1 - contains next in linked list -> compare to stored val in the JSON
        #if that number has changed, loop through the posts and check that each
  end

  private

    def load_library
      watched = JSON.load File.read ENV['WATCH_FILE']
      ignored = JSON.load File.read ENV['IGNORE_FILE']
      [watched, ignored]
    end

    def send_query contract, storage
      @eth.get_storage_at contract, storage
    end

    def eth_strings input
      input.scan(/../).map{ |x| x.hex }.reject{|c| c == 0}.pack('c*')
    end

    def iterate input
      last_place = input[-1]
      input[-1] = last_place.next
      input
    end

    def do_i_have_it? blob
      dn   = blob[42..-1]
      p 'dont have this'
      File.exists?(File.join(ENV['BLOBS_DIR'], dn))
    end

    def get_the_blob blob
      btih = blob[2..41]
      dn   = blob[42..-1]
      link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
      p 'getting_link'
      torrent  = @puller.create link
      p torrent
    end
end

if __FILE__==$0
  require './connect_ethereum_socket'
  require './connect_torrent'
  require 'yaml'
  require 'httparty'

  puller = TorrentAPI.new(
    username:   ENV['TORRENT_USER'],
    password:   ENV['TORRENT_PASS'],
    url:        ENV['TORRENT_RPC'],
    debug_mode: true
  )
  eth = ConnectEth.new :zmq, :cpp

  Subscribe.new puller, eth
end