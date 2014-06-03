#!/usr/bin/env ruby

require 'json'
require 'celluloid/zmq'

# methods - sent over ZMQ but using a standard JSONRPC structure.
#   * `makeBlob`:      make blob
#                      params: filename: "FILENAME" || filecontents: "CONTENTS"
#                      returns success: BLOB_ID or error
#   * `destroyBlob`:   destroy blob
#                      params: blob: "BLOB_ID"
#                      returns success: true or error
#   * `addBlobToK`:    add blob to group
#                      params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `rmBlobFromK`:   remove blob from contract
#                      params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `subscribeK`:    add a contract's blobs to the subscribed list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `unsubscribeK`   remove a contract's blobs from the subscribed list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `ignoreK`        add a contract to the ignore list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `unignoreK`      remove a contract's blobs from the ignored list
#                      params: contract: "CONTRACT_ADDRESS"
#                      returns success: true or error
#   * `publish`:       sugar for make blob + add to g
#                      params: filename: "FILENAME" || filecontents: "CONTENTS",
#                              contract: "CONTRACT_ADDRESS"
#                      returns success: BLOB_ID or error)
#   * `get`:           add a magnet link to the cache
#                      params: id: "BLOB_ID"
#                      returns success: true or error

Celluloid::ZMQ.init

class ConnectUI
  include Celluloid::ZMQ

  def initialize puller, eth
    @puller = puller
    @eth = eth

    @answer_socket = RepSocket.new
    @push_socket   = PubSocket.new

    begin
      @answer_socket.bind ENV['UI_RESPOND']
      @push_socket.bind ENV['UI_ANNOUNCE']
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D<-ui on port >>\t#{ENV['UI_RESPOND'].split(':').last}"
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D->ui on port >>\t#{ENV['UI_ANNOUNCE'].split(':').last}"
    rescue IOError
      @answer_socket.close
      @push_socket.close
    end
  end

  def run
    loop { async.handle_message @answer_socket.read }
    self.terminate
  end

  def handle_message message
    message = JSON.load message
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Question >>\tmethod:#{message['method']}\tparams:#{message['params']}"
    case message['method']
    when 'get'
      blob_id = message['params'][0]
      Getter.get @puller, blob_id
    when 'makeBlob'
      blob         = message['params'][0]
      PublishBlob.new blob, nil
    when 'destroyBlob'
      #todo
    when 'addBlobToK'
      sending_addr = message['params'][0]
      contract_id  = message['params'][1]
      group_id     = message['params'][2]
      PublishBlob.new nil, sending_addr, contract_id, group_id
    when 'rmBlobFromK'
      #todo
    when 'subscribeK'
      contract = message['params'][0]
      EyeOfZorax.subscribe contract
    when 'unsubscribeK'
      contract = message['params'][0]
      EyeOfZorax.unsubscribe contract
    when 'ignoreK'
      contract = message['params'][0]
      EyeOfZorax.ignore contract
    when 'unignoreK'
      contract = message['params'][0]
      EyeOfZorax.unignore contract
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