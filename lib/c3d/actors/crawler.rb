#!/usr/bin/env ruby

module C3D
  class Crawler
    include Celluloid

    def initialize contract
      @parse = find_the_peak contract
      @purge = []
      C3D::TreeBuilder.new @parse, @purge
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
end