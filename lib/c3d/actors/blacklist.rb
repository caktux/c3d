#!/usr/bin/env ruby

module C3D
  class Blacklist
    include Celluloid

    def initialize contract
      contract = Array(contract)
      C3D::TreeBuilder.new [], contract
    end
  end
end