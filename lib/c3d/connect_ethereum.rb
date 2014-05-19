#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'SocketIO'
require 'celluloid/autostart'

class EthereumSocketAPI
  include Celluloid

  def initialize command={}
    do_this = command['do_this']
    params  = command['params']
    client  = SocketIO.connect("http://localhost:31313", sync: true) do
      before_start do
        on_message {|message| puts message}
        on_json_message {|message| puts message}
        on_event('clientRequestsAddresses') {|message| puts message }
        on_disconnect {puts "I GOT A DISCONNECT"}
      end

      after_start do
        emit do_this, params
        emit 'clientRequestsAddresses', ''
      end
    end
  end
end

if __FILE__==$0
  command = {}
  command['do_this'] = 'clientRequestsAddBlob'
  command['params']  = [
    'a6cb63ec28c12929bee2d3567bf98f374a0b7167', #senderaddr
    '',                                         #value
    'd00383d79aaede0ed34fab69e932a878e00a8938', #recipientaddr
    '10000',                                    #gas
    '3',                                        #dataslots
    'newp',                                     #....data
    '0x2A519DE3379D1192150778F9A6B1F1FFD8EF0EDAC9C91FA7E6F1853700600000',
    '0x1d822cb2e4c60c3a8a85546304072b14fb9de94e2c0c608c4120b5d529590c9d'
  ]
  client = EthereumSocketAPI.new command
end