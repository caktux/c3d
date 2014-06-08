#!/usr/bin/env ruby

require 'json'
require 'celluloid/autostart'
require 'base64'

class Subscribe
  include Celluloid
  attr_accessor :groups, :blobs, :contracts

  def initialize
    @groups    = 0
    @blobs     = 0
    @contracts = 0
    load_library
    assemble_and_perform_queries
    p @groups.to_s + " || " + @blobs.to_s  + " || " + @contracts.to_s
  end

  def assemble_and_perform_queries
    until @watched.empty?
      get_the_contract @watched.shift
    end
  end

  private

    def load_library
      @watched = JSON.load File.read ENV['WATCH_FILE']
      @ignored = JSON.load File.read ENV['IGNORE_FILE']
    end

    def send_query contract, storage
      $eth.get_storage_at contract, storage
    end

    def iterate input
      last_place = input[-1]
      input[-1]  = last_place.next
      input
    end

    def do_i_have_it? blob
      begin
        dn   = blob[42..-1]
        f = File.exists?(File.join(ENV['BLOBS_DIR'], dn))
        @blobs += 1
      rescue
        return false
      end
      f
    end

    def get_the_blob blob
      begin
        btih = blob[2..41]
        dn   = blob[42..-1]
        link = "magnet:?xt=urn:btih:" + btih + "&dn=" + dn
        torrent  = $puller.create link
        return true
      rescue
        return false
      end
    end

    def ab? contract
      location     = send_query contract, '0x10'
      if location == '0x88554646ab'
        return true
      else
        return false
      end
    end

    def ba? contract
      location     = send_query contract, '0x10'
      if location == '0x88554646ba'
        return true
      else
        return false
      end
    end

    def get_the_contract contract
      @contracts += 1
      if ab? contract
        get_the_content contract
      elsif ba? contract
        group = {}
        group[:prev] = send_query contract, '0x18'
        until group[:prev] == '0x30'
          group = get_the_group contract, group[:prev]
          check_then_get_the_blob group[:cont]
          if group[:targ] and group[:type] == '0x01' and group[:behv] == '0x01'
            @watched.push group[:targ]
            @watched.uniq!
          end
        end
      end
    end

    def get_the_content contract
      #note, given an `ab` contract, this will retrieve its blob.
      blob = send_query contract, '0x13'
      check_then_get_the_blob blob
    end

    def check_then_get_the_blob blob
      # todo, check if in ignore, blacklisted, etc.
      get_the_blob blob unless do_i_have_it? blob
    end

    def get_the_group contract, group_id
      @groups += 1
      this_group        = {group: group_id}
      # * (linkID)+0 : (A)    : ContractTarget
      this_group[:targ] = send_query contract, this_group[:group]
      # * (linkID)+1 : (A)    : Previous link
      step              = iterate this_group[:group]
      this_group[:prev] = send_query contract, step
      # * (linkID)+2 : (A)    : Next link
      step              = iterate step
      this_group[:next] = send_query contract, step
      # * (linkID)+3 : (I)    : Type [ 0 => Contract || 1 => Blob || 2 => Datamodel Only ]
      step              = iterate step
      this_group[:type] = send_query contract, step
      # * (linkID)+4 : (V)    : Behaviour [0 => Ignore || 1 => Treat Normally || 2 => UI structure ||
      #                                    3 => Flash Notice || 4 => Datamodel list || 5 => Blacklist]
      step              = iterate step
      this_group[:behv] = send_query contract, step
      # * (linkID)+5 : (B||C) : Content
      step              = iterate step
      this_group[:cont] = send_query contract, step
      # * (linkID)+6 : (B||C) : Datamodel.json (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
      step              = iterate step
      this_group[:data] = send_query contract, step
      # * (linkID)+7 : (B||C) : UI structure (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
      step              = iterate step
      this_group[:uuii] = send_query contract, step
      # * (linkID)+8 : (V)    : Timestamp
      step              = iterate step
      this_group[:time] = send_query contract, step
      return this_group
    end

end

if __FILE__==$0
  require './connect_ethereum_socket'
  require './connect_torrent'
  require 'yaml'
  require 'httparty'

  $puller = TorrentAPI.new(
    username:   ENV['TORRENT_USER'],
    password:   ENV['TORRENT_PASS'],
    url:        ENV['TORRENT_RPC'],
    debug_mode: true
  )
  $eth = ConnectEth.new :zmq, :cpp

  Subscribe.new puller, eth
end