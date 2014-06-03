#!/usr/bin/env ruby
# based off of work by @mukaibot here: https://github.com/mukaibot/mktorrent/blob/master/lib/mktorrent.rb
# and work by @Burgestrand here: https://gist.github.com/Burgestrand/1733611
# note `rhash` dependency

module Utility
  def self.add_group_to_ethereum sending_addr, contract_id, title, eth
    message = {}
    message['command'] = 'transact'
    message['params']  = [
      sending_addr,    #sender_addr
      '',              #value
      contract_id,     #recipient_addr
      '10000',         #gas
      '2',             #data_slots
      'newt',          #....data
      title
    ]
    eth.write JSON.dump message
    ### somehow this is not currently working.
  end
end