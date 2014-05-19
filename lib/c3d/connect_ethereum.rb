#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'json'
require 'celluloid/zmq'

Celluloid::ZMQ.init

class ConnectEth
  include Celluloid::ZMQ

  def initialize
    @question_socket = ReqSocket.new
    begin
      @question_socket.connect ETH_ADDRESS
    rescue IOError
      @question_socket.close
    end
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D->eth on port >>\t#{ETH_ADDRESS.split(':').last}"
  end

  def write message
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Sending Question >>\t#{message}"
    @question_socket.send message
    handle_response JSON.load(@question_socket.read)
  end

  def handle_response response
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tsuccess:#{response['success']}\tanswer:#{response['answer']}"
  end
end

if __FILE__==$0
  ETH_ADDRESS = 'tcp://127.0.0.1:31315'

  message = {}
  message['command'] = 'c3dRequestsAddBlob'
  message['params']  = [
    'a6cb63ec28c12929bee2d3567bf98f374a0b7167', #senderaddr
    '',                                         #value
    'd00383d79aaede0ed34fab69e932a878e00a8938', #recipientaddr
    '10000',                                    #gas
    '3',                                        #dataslots
    'newp',                                     #....data
    '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600000',
    '0x1d822cb2e4c60c3a8a85546304072b14fb9de94e2c0c608c4120b5d529590c9d'
  ]
  questions_for_eth = ConnectEth.new
  questions_for_eth.write JSON.dump message

  message = {}
  message['command'] = 'c3dRequestsAddresses'
  questions_for_eth.write JSON.dump message

  message = {}
  message['command'] = 'c3dRequestsStorage'
  message['params'] = [
    'd00383d79aaede0ed34fab69e932a878e00a8938',
    '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600003'
  ]
  questions_for_eth.write JSON.dump message

  sleep
end
