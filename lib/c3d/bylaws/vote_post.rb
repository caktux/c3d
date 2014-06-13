#!/usr/bin/env ruby

class VotePost

  def initialize post_id, up_or_down, up_down_vote_bylaw
    if up_or_down == 'upvote' or up_or_down == 'downvote'
      if post_id
        build_transaction post_id, up_or_down, up_down_vote_bylaw
      end
    end
  end

  private

    def build_transaction post_id, up_or_down, up_down_vote_bylaw
      data      = [ up_or_down, post_id ]
      $eth.transact up_down_vote_bylaw, data
    end
end