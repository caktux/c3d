#!/usr/bin/env ruby

require 'json'
require 'celluloid/zmq'

# commands - sent over ZMQ but using a standard JSONRPC structure.
#   * `make-blob`:      make blob (params: filename: "FILENAME" || filecontents: "CONTENTS") (returns success: BLOB_ID or error)
#   * `destroy-blob`:   destroy blob (params: blob: "BLOB_ID") (returns success: true or error)
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `subscribe-k`:    add a contract's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `subscribe-g`:    add a group's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `unsubscribe-k`   remove a contract's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unsubscribe-g`   remove a group's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `ignore-g`        add a group to the ignore list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `publish`:        sugar for make blob + add to k + (opt) add to g (params: filename: "FILENAME" || filecontents: "CONTENTS", contract: "CONTRACT_ADDRESS", [optional] group: ["GROUP1_ID", "GROUP2_ID", ...]) (returns success: BLOB_ID or error)
#   * `get`:            add a magnet link to the cache (params: id: "BLOB_ID") (returns success: true or error)

Celluloid::ZMQ.init

class ConnectUI
  include Celluloid::ZMQ

  def initialize
    @answer_socket = RepSocket.new

    begin
      @answer_socket.bind UI_ADDRESS
    rescue IOError
      @answer_socket.close
      raise
    end

    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D<-ui on port >>\t#{UI_ADDRESS.split(':').last}"
  end

  def run
    loop { async.handle_message @answer_socket.read }
    self.terminate
  end

  def handle_message message
    message = JSON.load message
    @answer_socket.send(JSON.dump(message))
  end
end

if __FILE__==$0
  UI_ADDRESS   = 'tcp://127.0.0.1:31314'
  answers_for_eth  = ConnectUI.new
  answers_for_eth.async.run
end
