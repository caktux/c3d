#!/usr/bin/env ruby

require 'json'
require 'celluloid/zmq'

# commands - sent over ZMQ but using a standard JSONRPC structure.
#   * `makeBlob`:      make blob
#                      params: filename: "FILENAME" || filecontents: "CONTENTS"
#                      returns success: BLOB_ID or error
#   * `destroyBlob`:   destroy blob
#                      params: blob: "BLOB_ID"
#                      returns success: true or error
#   * `addBlobToG`:    add blob to group
#                      params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID"
#                      returns success: true or error
#   * `rmBlobFromG`:   remove blob from contract
#                      params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID"
#                      returns success: true or error
#   * `subscribeK`:    add a contract's blobs to the subscribed list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `subscribeG`:    add a group's blobs to the subscribed list
#                      params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID"
#                      returns success: true or error
#   * `unsubscribeK`   remove a contract's blobs from the subscribed list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `unsubscribeG`   remove a group's blobs from the subscribed list
#                      params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID"
#                      returns success: true or error
#   * `ignoreG`        add a group to the ignore list
#                      params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID"
#                      returns success: true or error
#   * `publish`:       sugar for make blob + add to g
#                      params: filename: "FILENAME" || filecontents: "CONTENTS",
#                              contract: "CONTRACT_ADDRESS", [group]: ["GROUP1_ID", "GROUP2_ID", ...]
#                      returns success: BLOB_ID or error)
#   * `get`:           add a magnet link to the cache
#                      params: id: "BLOB_ID"
#                      returns success: true or error

Celluloid::ZMQ.init

class ConnectUI
  include Celluloid::ZMQ

  def initialize
    @answer_socket = RepSocket.new

    begin
      @answer_socket.bind ENV['UI_ADDRESS']
    rescue IOError
      @answer_socket.close
      raise
    end

    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D<-ui on port >>\t#{ENV['UI_ADDRESS'].split(':').last}"
  end

  def run
    loop { async.handle_message @answer_socket.read }
    self.terminate
  end

  def handle_message message
    message = JSON.load message
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Question >>\tcommand:#{message['command']}\tparams:#{message['params']}"
    case message['command']
    when 'get'
      # todo
    when 'makeBlob'
      blob         = message['params'][0]
      PublishBlob.new blob, nil
    when 'destroyBlob'
      #todo
    when 'addBlobToG'
      sending_addr = message['params'][0]
      contract_id  = message['params'][1]
      group_id     = message['params'][2]
      PublishBlob.new nil, sending_addr, contract_id, group_id
    when 'rmBlobFromG'
      #todo
    when 'subscribeK'
      #todo
    when 'subscribeG'
      #todo
    when 'unsubscribeK'
      #todo
    when 'unsubscribeG'
      #todo
    when 'ignoreG'
      #todo
    when 'publish'
      sending_addr = message['params'][0]
      contract_id  = message['params'][1]
      group_id     = message['params'][2]
      blob         = message['params'][3]
      PublishBlob.new blob, sending_addr, contract_id, group_id
    end
    @answer_socket.send JSON.dump message
  end
end