#!/usr/bin/env ruby

module Utility
  extend self

  def save_key
    key = $eth.get_key
    config_file  = File.join(ENV['HOME'], '.epm', 'c3d-config.json')
    config = JSON.load(File.read(config_file))
    config["primary_account_key"] = key if config["primary_account_key"] != key
    ENV['ETH_KEY'] = config["primary_account_key"]
    File.open(config_file, 'w'){|f| f.write(JSON.pretty_generate(config))}
  end

  # def add_group_to_ethereum sending_addr, contract_id, title, eth
  #   message = {}
  #   message['command'] = 'transact'
  #   message['params']  = [
  #     sending_addr,    #sender_addr
  #     '',              #value
  #     contract_id,     #recipient_addr
  #     '10000',         #gas
  #     '2',             #data_slots
  #     'newt',          #....data
  #     title
  #   ]
  #   eth.write JSON.dump message
  #   ### somehow this is not currently working.
  # end

  # def ignore
end