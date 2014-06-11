#!/usr/bin/env ruby

class FlagPost

  def initialize post_id, flag_post_bylaw, flag_list_top
    if post_id
      build_transaction post_id, flag_post_bylaw
      get_values post_id, flag_list_top
    end
  end

  private

    def build_transaction post_id, flag_post_bylaw
      data      = [ post_id ]
      $eth.transact flag_post_bylaw, data
    end

    def get_values post_id, flag_list_top
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      post_position = $eth.get_storage_at flag_list_top, '0x19'
      if post_position == post_id
        return true
      else
        return false
      end
    end
end