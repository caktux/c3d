#!/usr/bin/env ruby
# based off of work by

class CreateThread
  attr_accessor :thread_id, :thread_blob

  def initialize blob, create_thread_bylaw, topic_id
    if blob
      build_transaction blob, create_thread_bylaw, topic_id
      get_values topic_id
    end
  end

  private

    def build_transaction blob, create_thread_bylaw, topic_id
      blob      = Blobber.new blob
      blob_id   = "0x#{blob.btih}#{blob.sha1_trun}"
      data      = [
          topic_id,            # topic_id
          blob_id,             # thread_blob_inner
          '',                  # thread_model_inner
          '',                  # thread_ui_inner
          blob_id,             # thread_blob_outer
          '',                  # thread_model_outer
          '',                  # thread_ui_outer
          blob_id,             # post_blob_inner
          '',                  # post_model_inner
          '',                  # post_ui_inner
          blob_id,             # post_blob_outer
          '',                  # post_model_outer
          ''                   # post_ui_outer
        ]
      $eth.transact create_thread_bylaw, data
    end

    def get_values topic_id
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      thread_memory_position = $eth.get_storage_at topic_id, '0x19'
      @thread_id             = $eth.get_storage_at topic_id, thread_memory_position
      post_memory_position   = $eth.get_storage_at @thread_id, '0x19'
      post_content_pos       = "0x" + ((post_memory_position.hex + 0x5).to_s(16))
      @thread_blob           = $eth.get_storage_at @thread_id, post_content_pos
    end
end