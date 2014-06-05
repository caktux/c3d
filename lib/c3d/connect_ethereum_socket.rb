#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'json'
require 'celluloid/zmq'

Celluloid::ZMQ.init

class ConnectEthZMQ
  include Celluloid::ZMQ

  def initialize
    @question_socket = ReqSocket.new
    begin
      @question_socket.connect ENV['ETH_ZMQ_ADDR']
    rescue IOError
      @question_socket.close
    end

    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D->eth via ZMQ and JS Socket on port >>\t#{ENV['ETH_ZMQ_ADDR'].split(':').last}"
  end

  def get_storage_at address, storage_location
    address          = guard_addresses address
    storage_location = guard_addresses storage_location

    request = {
                method: 'getStorageAt',
                params: [
                          address,
                          storage_location
                        ]
              }

    send_message request
  end

  def transact recipient, key='', data='', value=0, gas=10000
    recipient = guard_addresses recipient
    #todo -- add variable gas_price

    request = {
                method: 'transact',
                params: [
                          key, #todo -- fix this -- especially in the socket listeners.
                          value,
                          recipient,
                          gas,
                          data #todo -- audit this
                        ].flatten
              }

    send_message request
  end

  private

    def guard_addresses address
      unless address[0..1] == "0x"
        address = "0x" + address
      end
    end

    def send_message request
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Sending Question >>\t#{request}"
      @question_socket.send request.to_json
      handle_response JSON.load(@question_socket.read)
    end

    def handle_response response
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tsuccess:#{response['success']}\tanswer:#{response['answer']}"
      return response['answer']
    end
end

if __FILE__==$0
  ENV['ETH_ZMQ_ADDR'] = 'tcp://127.0.0.1:31315'

  message = {}
  message['method'] = 'transact'
  message['params']  = [
    'a6cb63ec28c12929bee2d3567bf98f374a0b7167', #senderaddr
    '',                                         #value
    '61363f0d19cfe71a5c130642016e37649610294b', #recipientaddr
    '10000',                                    #gas
    '3',                                        #dataslots
    'newp',                                     #....data
    '0x76A46EAB30845C1FA2C0E08243890CDFBF73D6421CFA5BF9169FFB98A3300000',
    '0x1d822cb2e4c60c3a8a85546304072b14fb9de94e2c0c608c4120b5d529590c9d'
  ]
  questions_for_eth = ConnectEth.new
  questions_for_eth.write JSON.dump message

  message = {}
  message['method'] = 'getStorageAt'
  message['params'] = [
    '61363f0d19cfe71a5c130642016e37649610294b',
    '0x76A46EAB30845C1FA2C0E08243890CDFBF73D6421CFA5BF9169FFB98A3300003'
  ]

  questions_for_eth.write JSON.dump message
  sleep
end
