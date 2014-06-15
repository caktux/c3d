#!/usr/bin/env ruby

module C3D
  class Blacklist
    include Celluloid

    def initialize contract
      contract = Array(contract)
      puts "[C3D::#{Time.now.strftime( "%F %T" )}] Running Blacklist."
      C3D::TreeBuilder.new [], contract
    end
  end
end