#!/usr/bin/env ruby

require 'celluloid/autostart'

class Crawler
  include Celluloid

  def initialize contract
    @parse = find_the_peak contract
    @purge = []
    TreeBuilder.new @parse, @purge
  end

  private
    def find_the_peak contract
      parent   = send_query contract, '0x14'
      until parent = '0x'
        child  = parent
        parent = send_query contract, '0x14'
      end
      return [child]
    end

    def send_query contract, storage
      $eth.get_storage_at contract, storage
    end
end

if __FILE__==$0
  require '../../c3d.rb'
  Crawler.new
end