#!/usr/bin/env ruby

require 'celluloid/autostart'

class Blacklist
  include Celluloid

  def initialize contract
    contract = Array(contract)
    TreeBuilder.new [], contract
  end
end

if __FILE__==$0
  require '../../c3d.rb'
  Blacklist.new
end