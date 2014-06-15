#!/usr/bin/env ruby

class MoveThread
  attr_accessor :moved, :topic_id

  def initialize thread_id, target_topic_id, move_thread_bylaw
    if thread_id
      build_transaction thread_id, target_topic_id, move_thread_bylaw
      get_values thread_id, target_topic_id
    end
  end

  private

    def build_transaction thread_id, target_topic_id, move_thread_bylaw
      data      = [ thread_id, target_topic_id ]
      $eth.transact move_thread_bylaw, data
    end

    def get_values thread_id, target_topic_id
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      post_position    = $eth.get_storage_at target_topic_id, '0x19'
      if post_position == thread_id
        @moved = true
      else
        @moved = false
      end
      @topic_id = $eth.get_storage_at thread_id, '0x14'
    end
end