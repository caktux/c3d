#!/usr/bin/env ruby

# Transactions:
#   * `add-blob-to-g`:  add blob to group (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `rm-blob-from-g`: remove blob from contract (params: blob: "BLOB_ID", contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)

require 'socket'
require 'json'

class ConnectEthRPC
  include Celluloid

  def initialize client, host=ENV['ETH_HOST'], port=ENV['ETH_PORT']
    @client = client
    @question_socket = TCPSocket.new host, port
    puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] c3D->eth via RPC on port >>\t#{ENV['ETH_PORT']}"
  end

  def get_storage_at address, storage_location
    address          = guard_addresses address
    storage_location = guard_addresses storage_location

    case @client
    when :go
      request = {
                  id: 1,
                  method: "EthereumApi.GetStorageAt",
                  params: [{
                              address: address,
                              key: storage_location
                          }]
                }
    when :cpp
      request = {
                  id: 1,
                  method: "storageAt",
                  params: [{
                              a: address,
                              x: storage_location
                          }]
                }
    end

    send_command request
  end

  def transact recipient, key='', data='', value=0, gas=10000, gas_price=100000
    recipient = guard_addresses recipient

    case @client
    when :go
      request = {
                  id: 1,
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
                  id: 1,
                  method: 'transact',
                  params: [{
                            sec: '',#todo: key,
                            xValue: value,
                            aDest: recipient,
                            bData: '',#todo: build_data data,
                            xGas: gas,
                            xGasPrice: gas_price
                          }]
                }
    end

    send_command request
  end

  def create body_file, endowment=0, key='', gas=10000, gas_price=100000
    body_content = File.read(body_file)

    case @client
    when :go
      request = {
                  id: 1,
                  method: "EthereumApi.Create",
                  params: [{
                              init: '',
                              body: body_content,
                              value: endowment,
                              gas: gas,
                              gasprice: gas_price
                          }]
                }
    when :cpp
      request = {
                  id: 1,
                  method: "create",
                  params: [{
                             sec: '',#todo: key,
                             xEndowment: endowment,
                             bCode: body_content,
                             xGas: gas,
                             xGasPrice: gas_price
                          }]
                }
    end

    send_command request
  end

  private

    def guard_addresses address
      unless address[0..1] == "0x"
        address = "0x" + address
      end
    end

    def build_data data
      if data.class == Array
        slots = data[0].to_i
        data.each do |piece|
          #todo, encode the pieces...
        end
      else
        return data
      end
    end

    def send_command request
      puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Sending Question >>\t#{request}"
      @question_socket.puts request.to_json
      handle_response JSON.parse(@question_socket.gets)
    end

    def handle_response response
      unless response["error"]
        puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tanswer:#{response['result']}"
        return JSON.parse(response["result"])
      else
        puts "[C3D-EPM::#{Time.now.strftime( "%F %T" )}] Received Answer >>\tERROR!"
        return nil
      end
    end
end
