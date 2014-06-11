#!/usr/bin/env ruby

class BlacklistPost
  def initialize post_id, blacklist_post_bylaw, blacklist_top
    if post_id
      build_transaction post_id, blacklist_post_bylaw
      get_values blacklist_top
    end
  end

  private

    def build_transaction post_id, blacklist_post_bylaw
      data      = [ post_id ]
      $eth.transact blacklist_post_bylaw, data
    end

    def get_values blacklist_top
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      post_position = $eth.get_storage_at blacklist_top, '0x18'
      if post_position == post_id
        return true
      else
        return false
      end
    end
end