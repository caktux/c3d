#!/usr/bin/env ruby

class DownVotePost

  def initialize post_id, down_vote_bylaw
    if post_id
      build_transaction post_id, down_vote_bylaw
    end
  end

  private

    def build_transaction post_id, down_vote_bylaw
      data      = [ 'downvote', post_id ]
      $eth.transact down_vote_bylaw, data
    end
end