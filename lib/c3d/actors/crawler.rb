#!/usr/bin/env ruby

require 'celluloid/autostart'

class Crawler
  include Celluloid

  def initialize contract
    @parse = find_the_peak contract
    @purge = []
    TreeBuilder.new @parse, @purge
    p @parse
    p @purge
  end

  private
    def find_the_peak contract
      parent   = send_query contract, '0x14'
      until parent == '0x'
        child  = parent
        parent = send_query parent, '0x14'
        break if child == parent
      end
      return [child]
    end

    def send_query contract, storage
      $eth.get_storage_at contract, storage
    end
end

if __FILE__==$0
  require '../../c3d.rb'
  Crawler.new '0x5ebcc2546960f26a54b684d0e9dbdc152476703e'
end