#!/usr/bin/env ruby

require 'celluloid/zmq'
require 'json'

ANSWER_ADDR   = 'tcp://127.0.0.1:31314'
QUESTION_ADDR = 'tcp://127.0.0.1:31315'

# commands - sent over ZMQ but using a standard JSONRPC structure.
#   * `make-blob`:      make blob (params: filename: "FILENAME" || filecontents: "CONTENTS") (returns success: BLOB_ID or error)
#   * `destroy-blob`:   destroy blob (params: blob: "BLOB_ID") (returns success: true or error)
#   * `add-blob-to-k`:  add blob to contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-k`: remove blob from group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS") (returns success: true or error)
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
    @question_socket = ReqSocket.new
    @counter = 0
    @messages = 0

    begin
      @answer_socket.bind(ANSWER_ADDR)
      @question_socket.bind(QUESTION_ADDR)
    rescue IOError
      @answer_socket.close
      @question_socket.close
      raise
    end

    puts "Starting CACHE_master Responder on port: #{ANSWER_ADDR.split(':').last} and pid: #{Process.pid}."
    puts "Starting CACHE_master Questioner on port: #{QUESTION_ADDR.split(':').last} and pid: #{Process.pid}."
  end

  def run
    guard = true
    while guard == true
      guard = handle_message @answer_socket.read
    end
    @answer_socket.close
    self.terminate
  end

  def handle_message(message)
    unless message == 'SHUTDOWN'
      @messages += 1
      message = JSON.load(message)
      @counter += message['val']
      message['val'] = @counter / @messages
      message['origin'] = "ruby.#{Process.pid}"
      @answer_socket.send(JSON.dump(message))
      true
    else
      false
    end
  end
end

ConnectUI.new.run