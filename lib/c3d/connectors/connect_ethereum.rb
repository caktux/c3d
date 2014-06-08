#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'net/http'
require 'uri'
require 'json'
require 'celluloid/autostart'

class ConnectEth
  include Celluloid

  def initialize client
    @client = client
    @uri = URI.parse "http://#{ENV['ETH_HOST']}:#{ENV['ETH_PORT']}"
    @question_socket = Net::HTTP.new @uri.host, @uri.port
    @request = Net::HTTP::Post.new @uri.request_uri
    @request.content_type = 'application/json'
    @last_push = Time.now
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D->eth via RPC on port >>\t#{ENV['ETH_PORT']}"
  end

  def get_storage_at address, storage_location
    address          = guard_addresses address
    storage_location = guard_addresses storage_location

    case @client
    when :go
      request = {
                  id: 'c3d-client',
                  method: "EthereumApi.GetStorageAt",
                  params: [{
                              address: address,
                              key: storage_location
                          }]
                }
    when :cpp
      request = {
                  method: "storageAt",
                  params: {
                              a: address,
                              x: storage_location
                          },
                  id: 'c3d-client',
                  jsonrpc: '2.0'
                }
    end

    send_command request
  end

  def transact recipient, data='', value='', gas='100000', gas_price='100000000000000'
    sleep 0.5 if ( Time.now - @last_push < 0.5 )
    recipient = guard_addresses recipient
    data = build_data data
    case @client
    when :go
      request = {
                  id: 'c3d-client',
                  method: "EthereumApi.Transact",
                  params: [{
                            recipient: recipient,
                            value: value,
                            gas: gas,
                            gasprice: gas_price
                          }]
                }
    when :cpp
      request = {
                  method: 'transact',
                  params: {
                            sec: ENV['ETH_KEY'],
                            xValue: value.to_s,
                            aDest: recipient,
                            bData: data,
                            xGas: gas.to_s,
                            xGasPrice: gas_price.to_s
                          },
                  id: 'c3d-client',
                  jsonrpc: '2.0'
                }
    end
    @last_push = Time.now
    send_command request
  end

  private

    def guard_addresses address
      unless address[0..1] == "0x"
        address = "0x" + address
      end
      address
    end

    def build_data data
      if data.class == Array
        builded = "0x"
        data.each do |piece|
          if piece[0..1] == "0x"
            piece = piece[2..-1]
            piece = piece.rjust(64,'0')
          else
            piece = piece.unpack('c*').map{|s| s.to_s(16)}.join('')
            piece = piece.ljust(64,'0')
          end
          builded << piece
        end
        return builded
      else
        return data
      end
    end

    def send_command request
      @request.body = request.to_json
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Sending Question >>\t#{@request.body}"
      handle_response JSON.parse(@question_socket.request(@request).body)
    end

    def handle_response response
      unless response["error"]
        puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tanswer:#{response['result']}"
        return response["result"]
      else
        puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tERROR!"
        return nil
      end
    end
end

if __FILE__==$0
  ENV['ETH_HOST']      = 'localhost'
  ENV['ETH_PORT']      = '9090'
  ENV['ETH_KEY']       = '0xd73568c5a032cd3f1d4b9a8c976dc34433d69cbbc7c64c41cff8d18b220cd94e'
  @eth = ConnectEth.new :cpp
  i = 0
  # 25.times do
    p @eth.transact '0x8694b1b125a58704a7d44716dd5f5b0e3055ad2b', ['0xf755208c68f1edf994ba424b6184c9bb57bdeaee', "thislinkisID#{i}", '0xa1a1', '0xb2b2', '0xc3c3', '0xd4d4', '0xe5e5', '0xf6f6']
    i += 1
  # end
end