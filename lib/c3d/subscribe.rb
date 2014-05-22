#!/usr/bin/env ruby

# Queries:
#   * `subscribe-k`:    add a contract's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `subscribe-g`:    add a group's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `unsubscribe-k`   remove a contract's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unsubscribe-g`   remove a group's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `ignore-g`        add a group to the ignore list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'json'
require 'celluloid/autostart'
require 'base64'

class Subscriber
  include Celluloid
  attr_accessor :tor_file, :blob_file, :sha1_trun

  def initialize action, eth
    @eth = eth
    case action
    when 'subscribeK'
      subscribe_k
    when 'subscribeG'
      subscribe_g
    when 'unsubscribeK'
      unsubscribe_k
    when 'unsubscribeG'
      unsubscribe_g
    when 'ignoreG'
      ignore_g
    when 'assembleQueries'
      assemble_queries
    end
  end

  def assemble_queries
    watched, ignored = load_library
    # watched[contract] = [group1,group2] || watched[contract]=[] <=all
    watched.each_key do |contract|
      latest_group = send_query contract, '0x18'
      # sleep 0.5
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
        next_blob = send_query contract, latest_blob
        latest_blob_author = latest_blob.next
        blob_id = send_query contract, latest_blob.next.next
        p next_blob
        p latest_blob_author
        p blob_id
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
      watched = JSON.load File.read WATCH_FILE
      ignored = JSON.load File.read IGNORE_FILE
      [watched, ignored]
    end

    def send_query contract, storage
      message = { 'command' => 'c3dRequestsStorage', 'params' => [ contract, storage ] }
      @eth.write JSON.dump message
    end

    def eth_strings input
      input.scan(/../).map{|x| x.hex }.reject{|c| c == 0}.pack('c*')
    end

    def iterate input
      last_place = input[-1]
      input[-1] = last_place.next
      input
    end
end

if __FILE__==$0
  require './connect_ethereum.rb'
  SWARM_DIR    = File.join(ENV['HOME'], '.cache', 'c3d')
  WATCH_FILE   = File.join(SWARM_DIR, 'watchers.json')
  IGNORE_FILE  = File.join(SWARM_DIR, 'ignored.json')
  ETH_ADDRESS  = 'tcp://127.0.0.1:31315'
  '4320838ed6aff9ad8df45e261780af69e7c599ba'
  '0x76A46EAB30845C1FA2C0E08243890CDFBF73D6421CFA5BF9169FFB98A3300000'
  questions_for_eth = ConnectEth.new
  Subscriber.new 'assembleQueries', questions_for_eth
end

# when storage 0x11 is 0x16 contract is empty.