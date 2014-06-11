#!/usr/bin/env ruby
# based off of work by

class PostToThread
  attr_accessor :post_id

  def initialize blob, post_to_thread_bylaw, thread_id
    if blob
      build_transaction blob, post_to_thread_bylaw, thread_id
      get_values thread_id
    end
  end

  private

    def build_transaction blob, post_to_thread_bylaw, thread_id
      blob      = Blobber.new blob
      blob_id   = "0x#{blob.btih}#{blob.sha1_trun}"
      data      = [
          thread_id,           # thread_id
          blob_id,             # blob_inner
          '',                  # model_inner
          '',                  # ui_inner
          blob_id,             # blob_outer
          '',                  # model_outer
          ''                   # ui_outer
        ]
      $eth.transact post_to_thread_bylaw, data
    end

    def get_values thread_id
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      post_memory_position = $eth.get_storage_at thread_id, '0x19'
      @post_id             = $eth.get_storage_at thread_id, post_memory_position
    end
end