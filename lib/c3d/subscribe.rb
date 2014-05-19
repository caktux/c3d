#!/usr/bin/env ruby

# Queries:
#   * `subscribe-k`:    add a contract's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `subscribe-g`:    add a group's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `unsubscribe-k`   remove a contract's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unsubscribe-g`   remove a group's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `ignore-g`        add a group to the ignore list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

class Subscriber
  include Celluloid
  attr_accessor :tor_file, :blob_file, :sha1_trun

  def initialize action
    case action
    when 'subscribe-k'
      subscribe_k
    when 'subscribe-g'
      subscribe_g
    when 'unsubscribe-k'
      unsubscribe_k
    when 'unsubscribe-g'
      unsubscribe_g
    when 'ignore-g'
      ignore_g
    when 'assemble-calls'
      assemble_queries
    end
  end

  def assemble_queries
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

end