#!/usr/bin/env ruby
# based off of work by

class CreateTopic
  attr_accessor :topic_id

  def initialize blob, create_topic_bylaw, swarum_top
    if blob
      build_transaction blob, create_topic_bylaw, swarum_top
      get_values swarum_top
    end
  end

  private

    def build_transaction blob, create_topic_bylaw, swarum_top
      blob      = Blobber.new blob
      blob_id   = "0x#{blob.btih}#{blob.sha1_trun}"
      data      = [
          swarum_top,          # swarum_top
          blob_id,             # blob_inner
          '',                  # model_inner
          '',                  # ui_inner
          blob_id,             # blob_outer
          '',                  # model_outer
          ''                   # ui_outer
        ]
      $eth.transact create_topic_bylaw, data
    end

    def get_values swarum_top
      sleep 0.1                # to make sure the client has received the tx and posted to state machine
      topic_memory_position = $eth.get_storage_at swarum_top, '0x19'
      @topic_id             = $eth.get_storage_at swarum_top, topic_memory_position
    end
end