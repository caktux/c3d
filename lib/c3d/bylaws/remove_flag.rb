#!/usr/bin/env ruby

class RemoveFlag
  attr_accessor :removed

  def initialize post_id, remove_flag_bylaw, flag_list_top
    if post_id
      build_transaction post_id, remove_flag_bylaw
      get_values post_id, flag_list_top
    end
  end

  private

    def build_transaction post_id, remove_flag_bylaw
      data      = [ post_id ]
      $eth.transact remove_flag_bylaw, data
    end

    def get_values post_id, flag_list_top
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      post_present         = $eth.get_storage_at flag_list_top, post_id
      if post_present == '0x'
        @removed = true
      else
        @removed = false
      end
    end
end